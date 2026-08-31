# Development Environment Setup

This document provides step-by-step instructions for bootstrapping, credential provisioning, and operating the **Development** infrastructure for the Peer Coaching Network.

---

## Environment Specifications

| Property | Value |
| :--- | :--- |
| **GCP Project ID** | `pcn-dev-506605` |
| **Project Name** | `PCN Dev` |
| **Billing Account ID** | `018509-815E33-AA145A` |
| **Primary Region** | `asia-south1` (Mumbai) |
| **Firestore Database ID** | `pcn-dev` (Native Mode, Deletion Protection Enabled) |
| **Remote State Bucket** | `gs://pcn-dev-506605-tfstate` |
| **Terraform Cache** | `terraform/.terraform.dev` |
| **Web App Custom Domain** | `https://dev-app.peercoachingnetwork.com` |
| **Landing Page Custom Domain** | `https://dev-www.peercoachingnetwork.com` |
| **Hosting Sites** | `dev-app-506605` (App), `dev-landing-506605` (Landing) |

---

## Step 1: Bootstrap Dev GCP Project & State Bucket

Run these commands in your terminal:

```bash
# 1. Set environment variables
export DEV_PROJECT_ID="pcn-dev-506605"
export BILLING_ACCOUNT_ID="018509-815E33-AA145A"
export REGION="asia-south1"

# 2. Authenticate gcloud CLI as your admin user
gcloud auth login

# 3. Create the Dev GCP Project (if not already created in GCP Console)
gcloud projects create "$DEV_PROJECT_ID" --name="PCN Dev"

# 4. Link Dev project to the Billing Account
gcloud billing projects link "$DEV_PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID"

# 5. Enable initial seed APIs (required for Terraform and GCS backend)
gcloud services enable \
  serviceusage.googleapis.com \
  cloudresourcemanager.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  --project="$DEV_PROJECT_ID"

# 6. Create the Terraform State GCS Bucket in asia-south1
gsutil mb -p "$DEV_PROJECT_ID" -l "$REGION" -b on "gs://${DEV_PROJECT_ID}-tfstate"

# 7. Enable object versioning on the state bucket
gsutil versioning set on "gs://${DEV_PROJECT_ID}-tfstate"

# 8. Create the Dev Terraform Service Account
gcloud iam service-accounts create terraform-sa \
  --project="$DEV_PROJECT_ID" \
  --description="Terraform Automation Service Account" \
  --display-name="Terraform SA"

# 9. Grant Owner permissions to the Dev Terraform Service Account
gcloud projects add-iam-policy-binding "$DEV_PROJECT_ID" \
  --member="serviceAccount:terraform-sa@${DEV_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/owner"
```

---

## Step 2: Download `dev-gcp-sa-key.json`

Generate and save the service account key to the Dev credentials directory:

```bash
# 1. Create local keys directory for dev
mkdir -p terraform/environments/dev/.keys

# 2. Generate and download dev-gcp-sa-key.json
gcloud iam service-accounts keys create "terraform/environments/dev/.keys/dev-gcp-sa-key.json" \
  --iam-account="terraform-sa@${DEV_PROJECT_ID}.iam.gserviceaccount.com" \
  --project="$DEV_PROJECT_ID"
```

> **Tip**: If you ever need to replace or re-download the Dev service account key, running the command above will generate a fresh `dev-gcp-sa-key.json` file.

---

## Step 3: Configure & Download Dev OAuth 2.0 Credentials

Google Sign-In is **mandatory** for the application. OAuth 2.0 Web Client credentials must be created via Google Cloud Console:

1. Open [Google Cloud Console Credentials](https://console.cloud.google.com/apis/credentials) and select your project (`pcn-dev-506605`).
2. Configure the **OAuth Consent Screen** (if not already done):
   - **User Type**: External
   - **App Name**: `Peer Coaching Network Dev`
   - **User Support Email** and **Developer Contact Email**: your admin email
3. Go to **Credentials** -> **+ Create Credentials** -> **OAuth Client ID**.
4. Select **Application type**: `Web application`.
5. Set **Name**: `Peer Coaching Network Web (dev)`.
6. Configure URIs:
   - **Authorized JavaScript origins**:
     - `https://dev-app.peercoachingnetwork.com`
     - `https://pcn-dev-506605.firebaseapp.com`
     - `http://localhost:5173`
   - **Authorized redirect URIs**:
     - `https://pcn-dev-506605.firebaseapp.com/__/auth/handler`
     - `https://dev-app.peercoachingnetwork.com/__/auth/handler`
7. Click **Create**, then click **Download JSON**.
8. Save the downloaded file to:
   ```
   terraform/environments/dev/.keys/dev-gcp-oauth-client-secret.json
   ```

---

## Step 4: Manage Dev Infrastructure with Make Commands

The repository Makefile automatically isolates the Dev Terraform state cache in `terraform/.terraform.dev/` and injects credentials from `terraform/environments/dev/.keys/`.

```bash
# 1. Initialize Terraform for Dev
make dev-init

# 2. Preview changes
make dev-plan

# 3. Apply changes (Must be run manually by human operator)
make dev-apply

# 4. View outputs (App SA email, Web App ID, Firestore details)
make dev-output

# 5. (Optional) Destroy infrastructure if decommissioning
make dev-destroy
```

---

## Step 5: Download `dev-firebase-web-app-config.json`

After running `make dev-apply` to register the Firebase Web App, download the client SDK configuration JSON using the Firebase CLI:

```bash
firebase apps:sdkconfig WEB --project="$DEV_PROJECT_ID" -o "terraform/environments/dev/.keys/dev-firebase-web-app-config.json"
```
