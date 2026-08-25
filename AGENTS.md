# AGENTS.md

This document contains critical architectural context, constraints, and operating instructions for AI coding assistants and autonomous agents interacting with this repository.

---

## ⛔ CRITICAL AGENT CONSTRAINTS & BANNED COMMANDS

> [!CAUTION]
> ### STRICT BAN ON EXECUTING `APPLY` AND `DESTROY` COMMANDS
> **AI AGENTS ARE STRICTLY PROHIBITED FROM EXECUTING ANY OF THE FOLLOWING COMMANDS:**
> - `make dev-apply`
> - `make prod-apply`
> - `make dev-destroy`
> - `make prod-destroy`
> - `terraform apply` (in any directory or with any flags)
> - `terraform destroy` (in any directory or with any flags)
> 
> **Rationale**: Infrastructure modifications, state commits, and deletions must undergo human review and MUST ONLY be executed manually by a human operator in their terminal.
> 
> **Allowed Agent Commands**:
> - `make fmt` / `terraform fmt`
> - `make dev-init` / `make prod-init`
> - `make dev-plan` / `make prod-plan`
> - `make dev-output` / `make prod-output`
> - `make clean`

---

## Repository Overview & Architecture

This repository manages the Google Cloud Platform (GCP) and Firebase infrastructure for the Peer Coaching Network across two fully isolated environments: **`dev`** and **`prod`**.

### Key Architectural Principles
1. **Decentralized Architecture (No Central Project)**:
   - `dev` and `prod` are independent GCP projects (`pcn-dev-506605` for Dev).
   - There is no central or shared management GCP project.
   - Each project hosts its own GCS remote state bucket (`<project_id>-tfstate`) in `asia-south1`.
2. **India Region (`asia-south1` - Mumbai)**:
   - All regional compute, Firestore, Cloud Functions, and Cloud Storage resources are located in Mumbai (`asia-south1`).
3. **Custom Firestore Databases**:
   - Dev database ID: `pcn-dev` (Native mode)
   - Prod database ID: `pcn-prod` (Native mode)
   - Both environments have `delete_protection_state = "DELETE_PROTECTION_ENABLED"` and `deletion_policy = "ABANDON"` hardcoded.
4. **Authentication Model (Google OAuth Only)**:
   - Identity Platform manages authentication.
   - **Google Sign-In is the ONLY allowed sign-in provider**.
   - Email/Password, Phone Number, and Anonymous sign-in providers are strictly **disabled**.
5. **Division of Responsibilities**:
   - **This Repository (Terraform)**: GCP APIs, Firebase enablement, Firestore instance, Web App registration, Storage bucket, Identity Platform auth with Google Sign-In, Application Service Account.
   - **Application Repository (Firebase CLI)**: `firestore.rules`, `storage.rules`, Cloud Functions deployments, and Web Hosting deployments (`firebase deploy`).

---

## Directory Structure & Keys Layout

```
peer-coaching-network-infrastructure/
├── Makefile                                # Environment-aware workflow commands
├── README.md                               # Human onboarding and bootstrap guide
├── AGENTS.md                               # Agent guidelines and operating instructions
└── terraform/
    ├── main.tf                             # Root module linking google_core and firebase
    ├── variables.tf                        # Root input variable definitions
    ├── outputs.tf                          # Root output definitions (unmasked, safe outputs only)
    ├── versions.tf                         # Terraform and Google/Google-Beta provider settings
    ├── modules/
    │   ├── google_core/                    # APIs, Identity Platform, App Service Account & IAM
    │   └── firebase/                       # Firebase project, Firestore DB, Web App, Storage
    └── environments/
        ├── dev/
        │   ├── backend.conf                # Dev GCS backend state bucket config
        │   ├── terraform.tfvars            # Dev environment input values
        │   └── .keys/                      # Git-ignored Dev credentials
        │       ├── dev-gcp-sa-key.json
        │       ├── dev-gcp-oauth-client-secret.json
        │       └── dev-firebase-web-app-config.json
        └── prod/
            ├── backend.conf                # Prod GCS backend state bucket config
            ├── terraform.tfvars            # Prod environment input values
            └── .keys/                      # Git-ignored Prod credentials
                ├── prod-gcp-sa-key.json
                ├── prod-gcp-oauth-client-secret.json
                └── prod-firebase-web-app-config.json
```

---

## Credential Handling & Fail-Fast Rules

1. **Self-Contained Credentials**:
   - All credentials must reside in `terraform/environments/<env>/.keys/` with explicit `dev-` and `prod-` prefixes.
   - All `.keys/` directories and JSON credential files are excluded in `.gitignore`.
2. **Native JSON Secret Parsing**:
   - OAuth client ID and client secret are parsed directly in `main.tf` via `jsondecode(file(...))`.
   - Never introduce `.env` files or hardcode secrets in `.tf` or `.tfvars` files.
3. **Mandatory Credential Pre-flight**:
   - Terraform and Make target checks require the presence of `<env>-gcp-sa-key.json` and `<env>-gcp-oauth-client-secret.json`.
   - If missing, execution fails immediately. For production or new developer setups, credentials must be obtained offline from team leads.

---

## Environment Cache Isolation (`TF_DATA_DIR`)

- **Dev Cache**: `terraform/.terraform.dev/`
- **Prod Cache**: `terraform/.terraform.prod/`
- **Implementation**: The `Makefile` configures `TF_DATA_DIR` and uses `terraform -chdir=terraform ...` for all invocations.
- **Workflow Benefit**: Once `make dev-init` and `make prod-init` have been executed, developers can run `make dev-plan` and `make prod-plan` interchangeably without re-initialization or cache clearing.
- **Lock File**: `.terraform.lock.hcl` in `terraform/` locks provider plugin versions across all environments.

---

## Sensitive Outputs Rule

- **Do NOT expose sensitive credentials in Terraform root outputs**:
  - The `firebase_web_app_config` output was removed from root outputs because sensitive attributes are masked by Terraform and client SDK configs are exported directly from data sources when needed.
  - Only safe identifiers (`project_id`, `environment`, `app_service_account_email`, `firestore_database_name`, `firestore_database_location`, `app_storage_bucket`, `firebase_web_app_id`) belong in `terraform/outputs.tf`.
