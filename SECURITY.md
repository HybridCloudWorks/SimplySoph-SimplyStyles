# Security policy

## Reporting a vulnerability

Please report security problems privately through GitHub: [open a private security advisory](https://github.com/HybridCloudWorks/SimplySoph-SimplyStyles/security/advisories/new) (Security tab, **Report a vulnerability**). Do not open a public issue, pull request or discussion for a security problem.

A useful report says what is affected (a screen, a Cloud Function or a file in this repository), how to reproduce it, and what an attacker could do with it. Please do not include real user photos, names or account details; describe them instead.

You will get an acknowledgement in the report thread. This is a small prototype with no bug bounty, so please give reasonable time for a fix before disclosing anything publicly.

## Scope

The code in this repository and its Cloud Functions. Out of scope: the third-party services the app uses (Google Cloud, Firebase, RapidAPI); report problems in those services to their vendors.

## Supported versions

Only the current `main` branch receives fixes.

For architecture and security design notes, see [docs/Security.md](docs/Security.md).
