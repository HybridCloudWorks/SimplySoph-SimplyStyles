#!/usr/bin/env bash
# Create a service account and key for Firebase Hosting deploy
# Usage: ./create_firebase_service_account.sh YOUR_PROJECT_ID service-account-name

PROJECT_ID="$1"
SA_NAME="$2"
if [ -z "$PROJECT_ID" ] || [ -z "$SA_NAME" ]; then
  echo "Usage: $0 <project-id> <service-account-name>"
  exit 1
fi

gcloud iam service-accounts create "$SA_NAME" --project "$PROJECT_ID" --display-name="$SA_NAME"

# Grant roles (Hosting deploy requires firebasehosting.admin or roles/editor)
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/firebasehosting.admin"

# Create JSON key
gcloud iam service-accounts keys create ./${SA_NAME}-key.json --iam-account="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" --project="$PROJECT_ID"

echo "Created key: ./${SA_NAME}-key.json"

echo "Copy contents to GitHub secret FIREBASE_SERVICE_ACCOUNT (escape newlines or base64 it)"
