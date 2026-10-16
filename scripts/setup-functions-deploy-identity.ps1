<#
.SYNOPSIS
    One-time setup for keyless (Workload Identity Federation) deploys of the
    SimplyStyles Cloud Functions to Firebase project simplysoph-66c78.

.DESCRIPTION
    Run this once, as a project Owner, with gcloud signed in (and gh signed in
    if you pass -SetRepoVariables). Preview it first with -WhatIf.

    It creates or reuses, in this order:
      1. The Google APIs that a 2nd-gen functions deploy calls (only the ones
         that are not enabled yet).
      2. A dedicated deploy service account (default:
         simplystyles-functions-deploy@<project>.iam.gserviceaccount.com).
      3. Least-privilege project roles for that account (see "Roles" below).
      4. Service Account User for that account on the functions runtime and
         build service account, and on the App Engine default service account
         (the Firebase CLI checks actAs on it before every functions deploy).
         No other service account.
      5. The project roles for Google-managed identities that firebase-tools
         would otherwise try to grant itself on the first 2nd-gen deploy of a
         codebase (which needs Project IAM Admin). Only missing ones are added.
      6. A separate OIDC provider in the existing "github-actions" pool. It only
         accepts tokens from this repository's main branch, pinned by the
         immutable repository and owner IDs. The website's provider
         (github-actions-provider) and its bindings are not touched.
      7. roles/iam.workloadIdentityUser on the deploy service account for
         tokens with this repository's ID.
      8. The repository variables GCP_WORKLOAD_IDENTITY_PROVIDER and
         GCP_SERVICE_ACCOUNT (printed as gh commands, or set with
         -SetRepoVariables).

    Every step reads the current state first and is skipped when it is already
    done, so the script is safe to run again. At the end it prints undo
    commands for everything it changed.

    Roles granted to the deploy service account (project level):
      roles/cloudfunctions.admin
          Create, update and delete functions (Cloud Functions v2 API). Admin
          rather than Developer because firebase-tools refuses to create new
          HTTPS or callable functions without
          cloudfunctions.functions.setIamPolicy, and then makes callables
          public with run.services.setIamPolicy; this role carries both, so
          Cloud Run Admin is not needed.
      roles/cloudscheduler.admin
          Create and update the Cloud Scheduler job for
          vortex_updateDailyTrends.
      roles/firebase.viewer
          Read-only. firebase.projects.get (the Admin SDK config the CLI passes
          to function discovery), storage.buckets.get (the storage trigger's
          bucket region), firebaseextensions.configs.list and
          resourcemanager.projects.getIamPolicy (CLI pre-deploy checks).
      roles/serviceusage.serviceUsageConsumer
          Lets the CLI check that the required APIs are enabled.
    Artifact Registry Writer is not granted: Cloud Build pushes the images, as
    the build service account. The CLI only reads the gcf-artifacts repository
    (artifactregistry.repositories.get, already in roles/cloudfunctions.admin)
    to check its cleanup policy.

    Sources (checked 2026-10-16):
      - Deployer roles, runtime and build service accounts:
        https://cloud.google.com/functions/docs/reference/iam/roles
      - Making a Cloud Run service public needs run.services.setIamPolicy:
        https://cloud.google.com/run/docs/authenticating/public
      - Workload Identity Federation for GitHub Actions:
        https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines
        https://github.com/google-github-actions/auth#preferred-direct-workload-identity-federation
      - firebase-tools 15.32.1 pre-deploy checks (actAs on the App Engine
        default service account, cloudfunctions.functions.setIamPolicy for new
        HTTPS functions, service agent bindings):
        https://github.com/firebase/firebase-tools/blob/v15.32.1/src/commands/deploy.ts
        https://github.com/firebase/firebase-tools/blob/v15.32.1/src/deploy/functions/checkIam.ts
        https://github.com/firebase/firebase-tools/blob/v15.32.1/src/deploy/functions/release/fabricator.ts

.PARAMETER ProjectId
    Firebase / Google Cloud project ID.

.PARAMETER ProjectNumber
    Project number. Checked against the project before any change.

.PARAMETER PoolId
    Existing workload identity pool to add the provider to. It is not created
    or changed by this script.

.PARAMETER ProviderId
    ID of the new OIDC provider (4-32 characters: lowercase letters, digits,
    hyphens).

.PARAMETER ServiceAccountId
    Account ID (the part before @) of the deploy service account.

.PARAMETER Repository
    GitHub repository, owner/name.

.PARAMETER RepositoryId
    Immutable GitHub repository ID:
    gh api repos/HybridCloudWorks/SimplySoph-SimplyStyles --jq '.id'

.PARAMETER RepositoryOwnerId
    Immutable GitHub owner (organization) ID:
    gh api repos/HybridCloudWorks/SimplySoph-SimplyStyles --jq '.owner.id'

.PARAMETER Branch
    The only branch whose workflow runs may use the provider.

.PARAMETER SetRepoVariables
    Also set the two GitHub repository variables with gh. Without it, the
    script prints the gh commands instead.

.EXAMPLE
    pwsh ./scripts/setup-functions-deploy-identity.ps1 -WhatIf

    Shows what would change, without changing anything.

.EXAMPLE
    pwsh ./scripts/setup-functions-deploy-identity.ps1 -SetRepoVariables

    Creates everything and sets the repository variables.
#>
#Requires -Version 7.2

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidatePattern('^[a-z][a-z0-9-]{4,28}[a-z0-9]$')]
    [string]$ProjectId = 'simplysoph-66c78',

    [ValidatePattern('^[0-9]+$')]
    [string]$ProjectNumber = '424903425639',

    [string]$PoolId = 'github-actions',

    [ValidatePattern('^[a-z0-9-]{4,32}$')]
    [string]$ProviderId = 'simplystyles-functions',

    [ValidatePattern('^[a-z][a-z0-9-]{4,28}[a-z0-9]$')]
    [string]$ServiceAccountId = 'simplystyles-functions-deploy',

    [ValidatePattern('^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$')]
    [string]$Repository = 'HybridCloudWorks/SimplySoph-SimplyStyles',

    [ValidatePattern('^[0-9]+$')]
    [string]$RepositoryId = '1087437215',

    [ValidatePattern('^[0-9]+$')]
    [string]$RepositoryOwnerId = '312844660',

    [ValidatePattern('^[A-Za-z0-9._/-]+$')]
    [string]$Branch = 'main',

    [switch]$SetRepoVariables
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Undo = [System.Collections.Generic.List[string]]::new()
$script:Changed = [System.Collections.Generic.List[string]]::new()

# --- helpers -----------------------------------------------------------------

function Invoke-Gcloud {
    # Runs gcloud and returns exit code, stdout and stderr. Throws on failure
    # unless -AllowFailure. -Retries covers IAM propagation delays right after
    # a service account is created.
    param(
        [Parameter(Mandatory)][string[]]$Arguments,
        [switch]$AllowFailure,
        [int]$Retries = 0
    )
    for ($attempt = 0; ; $attempt++) {
        # Capture stderr through the pipeline (2>&1), not a file: a file
        # redirection is itself skipped under -WhatIf.
        $ErrorActionPreference = 'Continue'
        $all = @(& gcloud @Arguments 2>&1)
        $code = $LASTEXITCODE
        $ErrorActionPreference = 'Stop'
        $stdout = @($all | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] } | ForEach-Object { "$_" })
        $stderr = (@($all | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] } | ForEach-Object { "$_" }) -join "`n").Trim()
        $result = [pscustomobject]@{
            ExitCode = $code
            StdOut   = ($stdout -join "`n").Trim()
            StdErr   = $stderr
        }
        if ($code -eq 0 -or $AllowFailure) { return $result }
        if ($attempt -ge $Retries) {
            throw "gcloud $($Arguments -join ' ') failed (exit $code): $stderr"
        }
        Write-Warning "gcloud failed (attempt $($attempt + 1) of $($Retries + 1)), retrying in 10 s: $stderr"
        Start-Sleep -Seconds 10
    }
}

function Get-GcloudJson {
    # Returns the parsed JSON output, or $null when the resource does not
    # exist. Any other error (permissions, network) stops the script.
    param([Parameter(Mandatory)][string[]]$Arguments)
    $r = Invoke-Gcloud -Arguments ($Arguments + '--format=json') -AllowFailure
    if ($r.ExitCode -ne 0) {
        if ($r.StdErr -match 'NOT_FOUND|not found|does not exist|Unknown service account') { return $null }
        throw "gcloud $($Arguments -join ' ') failed (exit $($r.ExitCode)): $($r.StdErr)"
    }
    if (-not $r.StdOut) { return $null }
    return $r.StdOut | ConvertFrom-Json
}

function Test-PolicyBinding {
    # True when the policy has an unconditional binding of Member to Role.
    param($Policy, [string]$Role, [string]$Member)
    if ($null -eq $Policy -or -not $Policy.PSObject.Properties['bindings']) { return $false }
    foreach ($binding in @($Policy.bindings)) {
        if ($binding.role -ne $Role) { continue }
        if ($binding.PSObject.Properties['condition']) { continue }
        if (@($binding.members) -contains $Member) { return $true }
    }
    return $false
}

function Invoke-Change {
    # Runs one change through ShouldProcess (-WhatIf / -Confirm) and records
    # its undo command.
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)][string]$Action,
        [Parameter(Mandatory)][scriptblock]$Command,
        [string]$UndoCommand
    )
    if ($PSCmdlet.ShouldProcess($Target, $Action)) {
        & $Command
        $script:Changed.Add("$Action -> $Target")
        Write-Host "  done: $Action -> $Target"
    }
    if ($UndoCommand) { $script:Undo.Add($UndoCommand) }
}

function Write-Section([string]$Text) {
    Write-Host ''
    Write-Host "== $Text" -ForegroundColor Cyan
}

# --- preflight ---------------------------------------------------------------

if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    throw 'gcloud is not on PATH. Install the Google Cloud CLI and run "gcloud auth login".'
}
if ($SetRepoVariables -and -not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'gh is not on PATH. Install the GitHub CLI and run "gh auth login", or omit -SetRepoVariables.'
}

$saEmail = "$ServiceAccountId@$ProjectId.iam.gserviceaccount.com"
$saMember = "serviceAccount:$saEmail"
$computeSa = "$ProjectNumber-compute@developer.gserviceaccount.com"
$appEngineSa = "$ProjectId@appspot.gserviceaccount.com"
$poolName = "projects/$ProjectNumber/locations/global/workloadIdentityPools/$PoolId"
$providerName = "$poolName/providers/$ProviderId"
$principalSet = "principalSet://iam.googleapis.com/$poolName/attribute.repository_id/$RepositoryId"
$attributeCondition = "assertion.repository_id == '$RepositoryId' && assertion.repository_owner_id == '$RepositoryOwnerId' && assertion.ref == 'refs/heads/$Branch'"
$attributeMapping = [ordered]@{
    'google.subject'                = 'assertion.sub'
    'attribute.repository'          = 'assertion.repository'
    'attribute.repository_id'       = 'assertion.repository_id'
    'attribute.repository_owner_id' = 'assertion.repository_owner_id'
    'attribute.ref'                 = 'assertion.ref'
}

Write-Section 'Preflight'
$account = Get-GcloudJson -Arguments @('auth', 'list', '--filter=status:ACTIVE')
if (-not $account) { throw 'No active gcloud account. Run "gcloud auth login".' }
Write-Host "  gcloud account: $(@($account)[0].account)"

$project = Get-GcloudJson -Arguments @('projects', 'describe', $ProjectId)
if (-not $project) { throw "Project $ProjectId was not found or is not visible to this account." }
if ("$($project.projectNumber)" -ne $ProjectNumber) {
    throw "Project $ProjectId has number $($project.projectNumber), not $ProjectNumber. Check -ProjectId and -ProjectNumber."
}
Write-Host "  project: $ProjectId ($ProjectNumber)"

if (Get-Command gh -ErrorAction SilentlyContinue) {
    $ErrorActionPreference = 'Continue'
    $ids = @(& gh api "repos/$Repository" --jq '.id, .owner.id' 2>&1 | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] } | ForEach-Object { "$_".Trim() })
    $ghExit = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($ghExit -eq 0 -and $ids.Count -eq 2) {
        if ($ids[0] -ne $RepositoryId -or $ids[1] -ne $RepositoryOwnerId) {
            throw "GitHub reports repository ID $($ids[0]) and owner ID $($ids[1]) for $Repository, not $RepositoryId and $RepositoryOwnerId."
        }
        Write-Host "  repository: $Repository (id $RepositoryId, owner id $RepositoryOwnerId), checked with gh"
    }
    else {
        Write-Warning "Could not check the repository IDs with gh; using $RepositoryId and $RepositoryOwnerId as given."
    }
}

$pool = Get-GcloudJson -Arguments @('iam', 'workload-identity-pools', 'describe', $PoolId, '--location=global', "--project=$ProjectId")
if (-not $pool) {
    throw "Workload identity pool $PoolId does not exist in $ProjectId. This script adds a provider to an existing pool; it does not create pools."
}
if ($pool.state -ne 'ACTIVE') { throw "Workload identity pool $PoolId is $($pool.state), not ACTIVE." }
Write-Host "  pool: $poolName (ACTIVE)"

$buildSa = $computeSa
$defaultBuild = Invoke-Gcloud -Arguments @('builds', 'get-default-service-account', "--project=$ProjectId", '--format=json') -AllowFailure
if ($defaultBuild.ExitCode -eq 0 -and $defaultBuild.StdOut) {
    $buildSa = (($defaultBuild.StdOut | ConvertFrom-Json).serviceAccountEmail -split '/')[-1]
}
else {
    Write-Warning "Could not read the default Cloud Build service account; assuming $computeSa. $($defaultBuild.StdErr)"
}
Write-Host "  functions runtime service account: $computeSa"
Write-Host "  Cloud Build service account: $buildSa"

# --- 1. APIs -----------------------------------------------------------------

Write-Section '1. Required APIs'
$requiredApis = @(
    'cloudfunctions.googleapis.com',
    'cloudbuild.googleapis.com',
    'artifactregistry.googleapis.com',
    'run.googleapis.com',
    'eventarc.googleapis.com',
    'pubsub.googleapis.com',
    'storage.googleapis.com',
    'cloudscheduler.googleapis.com',
    'iam.googleapis.com',
    'iamcredentials.googleapis.com',
    'sts.googleapis.com',
    'cloudresourcemanager.googleapis.com'
)
$enabled = @(Get-GcloudJson -Arguments @('services', 'list', '--enabled', "--project=$ProjectId") |
    ForEach-Object { ($_.name -split '/')[-1] })
$missingApis = @($requiredApis | Where-Object { $enabled -notcontains $_ })
if ($missingApis.Count -eq 0) {
    Write-Host '  all required APIs are already enabled'
}
else {
    Invoke-Change -Target $ProjectId -Action "enable APIs: $($missingApis -join ', ')" -Command {
        Invoke-Gcloud -Arguments (@('services', 'enable') + $missingApis + "--project=$ProjectId") | Out-Null
    } -UndoCommand "# APIs enabled by this script: $($missingApis -join ' '). The project is shared with the website; leave them enabled unless you are sure nothing else uses them."
}

# --- 2. Deploy service account ------------------------------------------------

Write-Section '2. Deploy service account'
$sa = Get-GcloudJson -Arguments @('iam', 'service-accounts', 'describe', $saEmail, "--project=$ProjectId")
$saIsNew = $false
if ($sa) {
    Write-Host "  exists: $saEmail"
}
else {
    $saIsNew = $true
    Invoke-Change -Target $saEmail -Action 'create service account' -Command {
        Invoke-Gcloud -Arguments @(
            'iam', 'service-accounts', 'create', $ServiceAccountId,
            "--project=$ProjectId",
            '--display-name=SimplyStyles functions deploy (WIF)',
            "--description=Keyless GitHub Actions deploy of the simplystyles functions codebase from $Repository"
        ) | Out-Null
    } -UndoCommand "gcloud iam service-accounts delete $saEmail --project=$ProjectId --quiet   # can be undeleted for 30 days: gcloud iam service-accounts undelete <unique-id> --project=$ProjectId"
}
$retries = if ($saIsNew) { 6 } else { 0 }

# --- 3. Project roles for the deploy service account --------------------------

Write-Section '3. Project roles for the deploy service account'
$deployRoles = @(
    'roles/cloudfunctions.admin',
    'roles/cloudscheduler.admin',
    'roles/firebase.viewer',
    'roles/serviceusage.serviceUsageConsumer'
)
$projectPolicy = Get-GcloudJson -Arguments @('projects', 'get-iam-policy', $ProjectId)
foreach ($role in $deployRoles) {
    if (Test-PolicyBinding -Policy $projectPolicy -Role $role -Member $saMember) {
        Write-Host "  already granted: $role"
        continue
    }
    Invoke-Change -Target $ProjectId -Action "grant $role to $saEmail" -Command {
        Invoke-Gcloud -Retries $retries -Arguments @(
            'projects', 'add-iam-policy-binding', $ProjectId,
            "--member=$saMember", "--role=$role", '--condition=None', '--quiet', '--format=none'
        ) | Out-Null
    } -UndoCommand "gcloud projects remove-iam-policy-binding $ProjectId --member=$saMember --role=$role --condition=None --quiet --format=none"
}

# --- 4. actAs on the runtime/build and App Engine default service accounts ----

Write-Section '4. Service Account User on the functions service accounts'
foreach ($actAsTarget in @($computeSa, $buildSa, $appEngineSa | Select-Object -Unique)) {
    $actAsTargetPolicy = Get-GcloudJson -Arguments @('iam', 'service-accounts', 'get-iam-policy', $actAsTarget, "--project=$ProjectId")
    if ($null -eq $actAsTargetPolicy) {
        $exists = Get-GcloudJson -Arguments @('iam', 'service-accounts', 'describe', $actAsTarget, "--project=$ProjectId")
        if (-not $exists) {
            Write-Host "  skipped: $actAsTarget does not exist"
            continue
        }
    }
    if (Test-PolicyBinding -Policy $actAsTargetPolicy -Role 'roles/iam.serviceAccountUser' -Member $saMember) {
        Write-Host "  already granted on $actAsTarget"
        continue
    }
    Invoke-Change -Target $actAsTarget -Action "grant roles/iam.serviceAccountUser to $saEmail" -Command {
        Invoke-Gcloud -Retries $retries -Arguments @(
            'iam', 'service-accounts', 'add-iam-policy-binding', $actAsTarget,
            "--project=$ProjectId", "--member=$saMember", '--role=roles/iam.serviceAccountUser',
            '--condition=None', '--quiet', '--format=none'
        ) | Out-Null
    } -UndoCommand "gcloud iam service-accounts remove-iam-policy-binding $actAsTarget --project=$ProjectId --member=$saMember --role=roles/iam.serviceAccountUser --condition=None --quiet --format=none"
}

# --- 5. Google-managed identities needed by 2nd-gen triggers ------------------

Write-Section '5. Roles for Google-managed identities (2nd-gen triggers)'
# The bindings firebase-tools checks (and tries to add with
# resourcemanager.projects.setIamPolicy) on the first 2nd-gen deploy of a
# codebase. Granting them here means the deploy account never needs to change
# the project IAM policy.
$agentBindings = @(
    @{ Member = "serviceAccount:service-$ProjectNumber@gs-project-accounts.iam.gserviceaccount.com"; Role = 'roles/pubsub.publisher'; Why = 'Cloud Storage events for onImageUpload' },
    @{ Member = "serviceAccount:service-$ProjectNumber@gcp-sa-pubsub.iam.gserviceaccount.com"; Role = 'roles/iam.serviceAccountTokenCreator'; Why = 'Pub/Sub push authentication' },
    @{ Member = "serviceAccount:$computeSa"; Role = 'roles/run.invoker'; Why = 'Eventarc and Cloud Scheduler invoke the functions as this account' },
    @{ Member = "serviceAccount:$computeSa"; Role = 'roles/eventarc.eventReceiver'; Why = 'Eventarc trigger for onImageUpload' }
)
foreach ($b in $agentBindings) {
    if (Test-PolicyBinding -Policy $projectPolicy -Role $b.Role -Member $b.Member) {
        Write-Host "  already granted: $($b.Role) to $($b.Member)"
        continue
    }
    $member = $b.Member
    $role = $b.Role
    Invoke-Change -Target $ProjectId -Action "grant $role to $member ($($b.Why))" -Command {
        Invoke-Gcloud -Arguments @(
            'projects', 'add-iam-policy-binding', $ProjectId,
            "--member=$member", "--role=$role", '--condition=None', '--quiet', '--format=none'
        ) | Out-Null
    } -UndoCommand "gcloud projects remove-iam-policy-binding $ProjectId --member=$member --role=$role --condition=None --quiet --format=none   # only once no 2nd-gen function in the project needs it"
}

# --- 6. Workload identity provider --------------------------------------------

Write-Section "6. Workload identity provider $ProviderId in pool $PoolId"
$provider = Get-GcloudJson -Arguments @(
    'iam', 'workload-identity-pools', 'providers', 'describe', $ProviderId,
    "--workload-identity-pool=$PoolId", '--location=global', "--project=$ProjectId"
)
if ($provider) {
    if ($provider.state -ne 'ACTIVE') {
        throw "Provider $providerName exists but is $($provider.state). Undelete it (gcloud iam workload-identity-pools providers undelete $ProviderId --workload-identity-pool=$PoolId --location=global --project=$ProjectId) or choose another -ProviderId."
    }
    if ($provider.attributeCondition -ne $attributeCondition) {
        throw "Provider $providerName exists with a different attribute condition:`n  $($provider.attributeCondition)`nexpected:`n  $attributeCondition`nThis script does not change existing providers. Fix it by hand or choose another -ProviderId."
    }
    Write-Host "  exists with the expected attribute condition: $providerName"
}
else {
    # The condition contains quotes and "&&", so pass the flags in a YAML file
    # (gcloud topic flags-file) instead of on the command line.
    $flagsFile = Join-Path ([System.IO.Path]::GetTempPath()) "wif-provider-$ProviderId.yaml"
    $yaml = @(
        "--workload-identity-pool: `"$PoolId`"",
        '--location: "global"',
        '--display-name: "SimplyStyles functions deploy"',
        "--description: `"GitHub Actions OIDC for $Repository ($Branch only)`"",
        '--issuer-uri: "https://token.actions.githubusercontent.com"',
        "--attribute-condition: `"$attributeCondition`"",
        '--attribute-mapping:'
    ) + @($attributeMapping.Keys | ForEach-Object { "  `"$_`": `"$($attributeMapping[$_])`"" }) -join "`n"
    Invoke-Change -Target $providerName -Action 'create OIDC provider' -Command {
        Set-Content -Path $flagsFile -Value $yaml -Encoding utf8NoBOM
        try {
            Invoke-Gcloud -Arguments @(
                'iam', 'workload-identity-pools', 'providers', 'create-oidc', $ProviderId,
                "--project=$ProjectId", "--flags-file=$flagsFile", '--format=none'
            ) | Out-Null
        }
        finally {
            Remove-Item -Path $flagsFile -Force -ErrorAction SilentlyContinue -WhatIf:$false
        }
    } -UndoCommand "gcloud iam workload-identity-pools providers delete $ProviderId --workload-identity-pool=$PoolId --location=global --project=$ProjectId --quiet   # soft delete; restore within 30 days with: gcloud iam workload-identity-pools providers undelete $ProviderId --workload-identity-pool=$PoolId --location=global --project=$ProjectId"
    Write-Host "  attribute condition: $attributeCondition"
}

# --- 7. workloadIdentityUser binding -------------------------------------------

Write-Section '7. Let this repository impersonate the deploy service account'
$saPolicy = if ($saIsNew) { $null } else {
    Get-GcloudJson -Arguments @('iam', 'service-accounts', 'get-iam-policy', $saEmail, "--project=$ProjectId")
}
if (Test-PolicyBinding -Policy $saPolicy -Role 'roles/iam.workloadIdentityUser' -Member $principalSet) {
    Write-Host "  already granted: roles/iam.workloadIdentityUser to $principalSet"
}
else {
    Invoke-Change -Target $saEmail -Action "grant roles/iam.workloadIdentityUser to $principalSet" -Command {
        Invoke-Gcloud -Retries $retries -Arguments @(
            'iam', 'service-accounts', 'add-iam-policy-binding', $saEmail,
            "--project=$ProjectId", "--member=$principalSet", '--role=roles/iam.workloadIdentityUser',
            '--condition=None', '--quiet', '--format=none'
        ) | Out-Null
    } -UndoCommand "gcloud iam service-accounts remove-iam-policy-binding $saEmail --project=$ProjectId --member=$principalSet --role=roles/iam.workloadIdentityUser --condition=None --quiet --format=none"
}

# --- 8. GitHub repository variables -------------------------------------------

Write-Section '8. GitHub repository variables'
$variables = [ordered]@{
    GCP_WORKLOAD_IDENTITY_PROVIDER = $providerName
    GCP_SERVICE_ACCOUNT            = $saEmail
}
foreach ($name in $variables.Keys) {
    $value = $variables[$name]
    $ghCommand = "gh variable set $name --repo $Repository --body `"$value`""
    if ($SetRepoVariables) {
        Invoke-Change -Target "$Repository variable $name" -Action "set to $value" -Command {
            & gh variable set $name --repo $Repository --body $value
            if ($LASTEXITCODE -ne 0) { throw "gh variable set $name failed (exit $LASTEXITCODE)." }
        } -UndoCommand "gh variable delete $name --repo $Repository"
    }
    else {
        Write-Host "  run: $ghCommand"
    }
}

# --- summary -------------------------------------------------------------------

Write-Section 'Summary'
Write-Host "  GCP_WORKLOAD_IDENTITY_PROVIDER = $providerName"
Write-Host "  GCP_SERVICE_ACCOUNT            = $saEmail"
if ($WhatIfPreference) {
    Write-Host '  -WhatIf: nothing was changed.'
}
elseif ($script:Changed.Count -eq 0) {
    Write-Host '  Nothing to change: everything was already in place.'
}
else {
    Write-Host "  Changed $($script:Changed.Count) item(s)."
}

Write-Host ''
Write-Host 'Next steps:'
Write-Host "  1. Run the deploy: gh workflow run firebase-hosting-deploy.yml --repo $Repository --ref $Branch"
Write-Host "     (or Actions > CI/CD - Build, Test & Deploy > Run workflow, on $Branch)."
Write-Host "  2. After a green deploy, delete the old token secret: gh secret delete FIREBASE_TOKEN --repo $Repository"

if ($script:Undo.Count -gt 0) {
    Write-Section $(if ($WhatIfPreference) { 'Undo commands (for the changes above, if you apply them)' } else { 'Undo commands (run in this order to restore the previous state)' })
    for ($i = $script:Undo.Count - 1; $i -ge 0; $i--) {
        Write-Host "  $($script:Undo[$i])"
    }
}
