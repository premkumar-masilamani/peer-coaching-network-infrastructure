# Terraform for the Peer Coaching Network

### Key Design Highlights
1. **Decentralized (No Central Project)**: `dev` and `prod` are isolated GCP projects. There is no shared management project.
2. **Dedicated State Storage in GCS**: Each environment stores its own Terraform state in its own project's GCS bucket.
3. **Automated Credentials & Secrets Loading**:
   - Dev credentials: `terraform/environments/dev/.keys/gcp-sa-key.json` and `terraform/environments/dev/.keys/gcp-oauth-client-secret.json`
   - Prod credentials: `terraform/environments/prod/.keys/gcp-sa-key.json` and `terraform/environments/prod/.keys/gcp-oauth-client-secret.json`
   - All credentials live self-contained inside `environments/<env>/.keys/` (git-ignored) and are auto-detected by Terraform/Makefile.
4. **Mandatory Credential Pre-flight**: If the SA key or OAuth client secret file is missing from `terraform/environments/<env>/.keys/`, Terraform execution will fail fast. For projects already in production or new team members onboarding, obtain these environment-specific files offline from the team leads.
5. **Environment Isolation via `TF_DATA_DIR`**: Dev and Prod maintain independent local caches (`.terraform.dev` and `.terraform.prod`). Once initialized, you can switch between environments interchangeably without re-initializing or wiping caches.
6. **India Region (`asia-south1` - Mumbai)**: All regional compute, Firestore, Cloud Functions, and Cloud Storage resources reside in Mumbai for minimum latency for India-based users.
7. **Custom Firestore Database Instances**:
   - Dev: `pcn-dev` (with deletion protection enabled)
   - Prod: `pcn-prod` (with deletion protection enabled)
8. **Maximum Terraform Coverage**: Aside from the one-time project bootstrap, all APIs, Firebase settings, Auth providers (with mandatory Google Sign-In), database instances, storage buckets, and application service accounts are provisioned and tracked by Terraform.

---

## Division of Responsibilities

| Responsibility Area | Handled By | Details |
| :--- | :--- | :--- |
| **GCP Projects & State** | **This Repo (Terraform)** | Project setup, GCS state buckets, service account permissions |
| **GCP & Firebase APIs** | **This Repo (Terraform)** | Enables all 13 services (Firestore, Auth, Functions, Build, Run, etc.) |
| **Database & Storage** | **This Repo (Terraform)** | Provisions Firestore (`pcn-dev` / `pcn-prod`) with deletion protection and Firebase Storage bucket |
| **Authentication** | **This Repo (Terraform)** | Identity Platform, Email/Password, and mandatory Google OAuth Sign-In provider |
| **Web App Registration** | **This Repo (Terraform)** | Registers Firebase Web App |
| **Security Rules** | **App Repo (Firebase CLI)** | `firestore.rules` and `storage.rules` deployed via `firebase deploy --only firestore:rules,storage` |
| **Cloud Functions** | **App Repo (Firebase CLI)** | Function source code and deployment via `firebase deploy --only functions` |
| **Frontend Web App** | **App Repo (Firebase CLI)** | Application build and hosting via `firebase deploy --only hosting` |

---

## Prerequisites

Before starting, ensure you have the following installed on your machine:

1. **[Google Cloud CLI (`gcloud` / `gsutil`)](https://cloud.google.com/sdk/docs/install)**
2. **[Terraform](https://developer.hashicorp.com/terraform/downloads)** (>= 1.5.0)
3. **[Make](https://www.gnu.org/software/make/)**
4. An active **GCP Billing Account**. Retrieve your Billing Account ID:
   ```bash
   gcloud billing accounts list
   ```

---

## Step 1: Bootstrap the Dev Environment (Manual 1-Time Setup)

Run the following commands in your terminal to bootstrap the `dev` GCP project:

```bash
# 1. Set your variables
export DEV_PROJECT_ID="pcn-dev-506605"            # Your Dev Project ID
export BILLING_ACCOUNT_ID="012345-6789AB-CDEF01"  # Your GCP Billing Account ID
export REGION="asia-south1"

# 2. Authenticate your gcloud CLI
gcloud auth login

# 3. Create the Dev GCP Project (if not already created)
gcloud projects create "$DEV_PROJECT_ID" --name="Peer Coaching Network Dev"

# 4. Link the Project to your Billing Account
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

# Enable object versioning on the state bucket
gsutil versioning set on "gs://${DEV_PROJECT_ID}-tfstate"

# 7. Create the Terraform Service Account
gcloud iam service-accounts create terraform-sa \
  --project="$DEV_PROJECT_ID" \
  --description="Terraform Automation Service Account" \
  --display-name="Terraform SA"

# 8. Grant Owner permissions to the Terraform Service Account
gcloud projects add-iam-policy-binding "$DEV_PROJECT_ID" \
  --member="serviceAccount:terraform-sa@${DEV_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/owner"

# 9. Generate and download the Service Account Key JSON
mkdir -p terraform/environments/dev/.keys
gcloud iam service-accounts keys create "terraform/environments/dev/.keys/gcp-sa-key.json" \
  --iam-account="terraform-sa@${DEV_PROJECT_ID}.iam.gserviceaccount.com" \
  --project="$DEV_PROJECT_ID"
```

---

## Step 2: Bootstrap the Prod Environment (Manual 1-Time Setup)

Run the following commands in your terminal to bootstrap the `prod` GCP project:

```bash
# 1. Set your variables
export PROD_PROJECT_ID="your-prod-project-id"     # e.g., pcn-prod-12345
export BILLING_ACCOUNT_ID="012345-6789AB-CDEF01"  # Your GCP Billing Account ID
export REGION="asia-south1"

# 2. Create the Prod GCP Project
gcloud projects create "$PROD_PROJECT_ID" --name="Peer Coaching Network Prod"

# 3. Link the Project to your Billing Account
gcloud billing projects link "$PROD_PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID"

# 4. Enable initial seed APIs
gcloud services enable \
  serviceusage.googleapis.com \
  cloudresourcemanager.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  --project="$PROD_PROJECT_ID"

# 5. Create the Terraform State GCS Bucket in asia-south1
gsutil mb -p "$PROD_PROJECT_ID" -l "$REGION" -b on "gs://${PROD_PROJECT_ID}-tfstate"

# Enable object versioning on the state bucket
gsutil versioning set on "gs://${PROD_PROJECT_ID}-tfstate"

# 6. Create the Terraform Service Account
gcloud iam service-accounts create terraform-sa \
  --project="$PROD_PROJECT_ID" \
  --description="Terraform Automation Service Account" \
  --display-name="Terraform SA"

# 7. Grant Owner permissions to the Terraform Service Account
gcloud projects add-iam-policy-binding "$PROD_PROJECT_ID" \
  --member="serviceAccount:terraform-sa@${PROD_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/owner"

# 8. Generate and download the Service Account Key JSON
mkdir -p terraform/environments/prod/.keys
gcloud iam service-accounts keys create "terraform/environments/prod/.keys/gcp-sa-key.json" \
  --iam-account="terraform-sa@${PROD_PROJECT_ID}.iam.gserviceaccount.com" \
  --project="$PROD_PROJECT_ID"
```

---

## Step 3: OAuth 2.0 Credentials (for Google Sign-In)

Google Sign-In is **mandatory** for the application. To configure OAuth credentials:

1. Open [Google Cloud Console Credentials Page](https://console.cloud.google.com/apis/credentials).
2. Select your project (`pcn-dev-506605` or your prod project).
3. Configure the **OAuth Consent Screen** (User Type: External, App Name: `Peer Coaching Network`).
4. Go to **Credentials** -> **Create Credentials** -> **OAuth Client ID** -> **Web application**.
5. Click **Download JSON** on the created OAuth Client ID.
6. Save the downloaded JSON directly to:
   - For Dev: `terraform/environments/dev/.keys/gcp-oauth-client-secret.json`
   - For Prod: `terraform/environments/prod/.keys/gcp-oauth-client-secret.json`

*(Note: If either file is missing, Terraform execution will fail fast. For existing projects, obtain them offline from your team leads).*

---

## Step 4: Running Dev & Prod via Make Commands

### Managing the Development Environment

```bash
# 1. Initialize Terraform for Dev
make dev-init

# 2. Preview the changes
make dev-plan

# 3. Apply changes to Dev
make dev-apply

# 4. View outputs (App SA email, Web App ID, Firestore details)
make dev-output
```

### Managing the Production Environment

```bash
# 1. Initialize Terraform for Prod (uses independent .terraform.prod cache)
make prod-init

# 2. Preview the changes
make prod-plan

# 3. Apply changes to Prod
make prod-apply

# 4. View outputs
make prod-output
```

---

## Security Best Practices

1. **Keep `.keys/` Git-Ignored**: All service account keys and OAuth secret JSON files are stored in `terraform/environments/<env>/.keys/` which is ignored by `.git`. Never commit credentials to version control.
2. **Offline Credential Hand-off**: For production or new developer onboarding, team leads can simply share the specific environment's `.keys/` folder through an offline/secure channel.
3. **Environment Isolation via `TF_DATA_DIR`**: The Makefile automatically isolates Dev and Prod into independent data caches (`.terraform.dev` and `.terraform.prod`). Once initialized with `make dev-init` and `make prod-init`, you can run `dev` and `prod` commands interchangeably without needing to re-initialize or clean caches.
