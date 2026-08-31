# Production Environment Setup

This document provides step-by-step instructions for bootstrapping, credential provisioning, and operating the **Production** infrastructure for the Peer Coaching Network.

---

## Environment Specifications

| Property | Value |
| :--- | :--- |
| **GCP Project ID** | `pcn-prod-507207` |
| **Project Name** | `PCN prod` |
| **Billing Account ID** | `018509-815E33-AA145A` |
| **Primary Region** | `asia-south1` (Mumbai) |
| **Firestore Database ID** | `pcn-prod` (Native Mode, Deletion Protection Enabled) |
| **Remote State Bucket** | `gs://pcn-prod-507207-tfstate` |
| **Terraform Cache** | `terraform/.terraform.prod` |
| **Web App Custom Domain** | `https://app.peercoachingnetwork.com` |
| **Landing Page Custom Domain** | `https://www.peercoachingnetwork.com` |
| **Hosting Sites** | `pcn-prod-507207` (App - Default Site), `prod-landing-507207` (Landing) |

---

## Step 1: Bootstrap Prod GCP Project & State Bucket

Run these commands in your terminal:

```bash
# 1. Set environment variables
export PROD_PROJECT_ID="pcn-prod-507207"
export BILLING_ACCOUNT_ID="018509-815E33-AA145A"
export REGION="asia-south1"

# 2. Authenticate gcloud CLI as your admin user (ensure you are NOT authenticated as dev SA)
gcloud auth login

# 3. Create the Prod GCP Project (if not already created in GCP Console)
gcloud projects create "$PROD_PROJECT_ID" --name="PCN prod"

# 4. Link Prod project to the Billing Account
gcloud billing projects link "$PROD_PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID"

# 5. Enable initial seed APIs (required for Terraform and GCS backend)
gcloud services enable \
  serviceusage.googleapis.com \
  cloudresourcemanager.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  --project="$PROD_PROJECT_ID"

# 6. Create the Terraform State GCS Bucket in asia-south1
gsutil mb -p "$PROD_PROJECT_ID" -l "$REGION" -b on "gs://${PROD_PROJECT_ID}-tfstate"

# 7. Enable object versioning on the state bucket
gsutil versioning set on "gs://${PROD_PROJECT_ID}-tfstate"

# 8. Create the Prod Terraform Service Account
gcloud iam service-accounts create terraform-sa \
  --project="$PROD_PROJECT_ID" \
  --description="Terraform Automation Service Account" \
  --display-name="Terraform SA"

# 9. Grant Owner permissions to the Prod Terraform Service Account
gcloud projects add-iam-policy-binding "$PROD_PROJECT_ID" \
  --member="serviceAccount:terraform-sa@${PROD_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/owner"
```

---

## Step 2: Download `prod-gcp-sa-key.json`

Generate and save the service account key to the Prod credentials directory:

```bash
# 1. Create local keys directory for prod
mkdir -p terraform/environments/prod/.keys

# 2. Generate and download prod-gcp-sa-key.json
gcloud iam service-accounts keys create "terraform/environments/prod/.keys/prod-gcp-sa-key.json" \
  --iam-account="terraform-sa@${PROD_PROJECT_ID}.iam.gserviceaccount.com" \
  --project="$PROD_PROJECT_ID"
```

> **Tip**: If you ever need to replace or re-download the Prod service account key, running the command above will generate a fresh `prod-gcp-sa-key.json` file.

---

## Step 3: Configure & Download Prod OAuth 2.0 Credentials

Google Sign-In is **mandatory** for the application. OAuth 2.0 Web Client credentials must be created via Google Cloud Console:

1. Open [Google Cloud Console Credentials](https://console.cloud.google.com/apis/credentials) and select your project (`pcn-prod-507207`).
2. Configure the **OAuth Consent Screen** (if not already done):
   - **User Type**: External
   - **App Name**: `Peer Coaching Network Prod`
   - **User Support Email** and **Developer Contact Email**: your admin email
3. Go to **Credentials** -> **+ Create Credentials** -> **OAuth Client ID**.
4. Select **Application type**: `Web application`.
5. Set **Name**: `Peer Coaching Network Web (prod)`.
6. Configure URIs:
   - **Authorized JavaScript origins**:
     - `https://app.peercoachingnetwork.com`
     - `https://pcn-prod-507207.firebaseapp.com`
   - **Authorized redirect URIs**:
     - `https://pcn-prod-507207.firebaseapp.com/__/auth/handler`
     - `https://app.peercoachingnetwork.com/__/auth/handler`
7. Click **Create**, then click **Download JSON**.
8. Save the downloaded file to:
   ```
   terraform/environments/prod/.keys/prod-gcp-oauth-client-secret.json
   ```

---

## Step 4: Manage Prod Infrastructure with Make Commands

The repository Makefile automatically isolates the Prod Terraform state cache in `terraform/.terraform.prod/` and injects credentials from `terraform/environments/prod/.keys/`.

```bash
# 1. Initialize Terraform for Prod
make prod-init

# 2. Preview changes
make prod-plan

# 3. Apply changes (Must be run manually by human operator)
make prod-apply

# 4. View outputs (App SA email, Web App ID, Firestore details)
make prod-output

# 5. (Optional) Destroy infrastructure if decommissioning
make prod-destroy
```

---

## Step 5: Download `prod-firebase-web-app-config.json`

After running `make prod-apply` to register the Firebase Web App, download the client SDK configuration JSON using the Firebase CLI:

```bash
firebase apps:sdkconfig WEB --project="$PROD_PROJECT_ID" -o "terraform/environments/prod/.keys/prod-firebase-web-app-config.json"
```
