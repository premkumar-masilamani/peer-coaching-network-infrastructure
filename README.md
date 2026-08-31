# Terraform for the Peer Coaching Network

Infrastructure as Code (IaC) repository for provisioning and managing the Google Cloud Platform (GCP) and Firebase infrastructure for the Peer Coaching Network.

> **Application Codebase**: The frontend web application, Firebase security rules, and Cloud Functions are maintained in the **[`peer-coaching-network`](https://github.com/premkumar-masilamani/peer-coaching-network)** repository.

---

## Key Design Highlights

1. **Decentralized Architecture (No Central Project)**: `dev` and `prod` are completely isolated GCP projects (`pcn-dev-506605` and `pcn-prod-507207`). There is no shared management project.
2. **Dedicated State Storage in GCS**: Each environment stores its own Terraform state in its own project's GCS bucket (`asia-south1`).
3. **Automated Credentials & Secrets Loading**:
   - Dev credentials: `terraform/environments/dev/.keys/dev-gcp-sa-key.json`, `terraform/environments/dev/.keys/dev-gcp-oauth-client-secret.json`, and `terraform/environments/dev/.keys/dev-firebase-web-app-config.json`
   - Prod credentials: `terraform/environments/prod/.keys/prod-gcp-sa-key.json`, `terraform/environments/prod/.keys/prod-gcp-oauth-client-secret.json`, and `terraform/environments/prod/.keys/prod-firebase-web-app-config.json`
   - All credentials live self-contained inside `environments/<env>/.keys/` (git-ignored) with explicit `dev-` and `prod-` prefixes.
4. **Mandatory Credential Pre-flight**: If the SA key or OAuth client secret file is missing from `terraform/environments/<env>/.keys/`, Terraform execution will fail fast.
5. **Environment Isolation via `TF_DATA_DIR`**: Dev and Prod maintain independent local caches (`.terraform.dev` and `.terraform.prod`). Once initialized, you can switch between environments interchangeably without re-initializing or wiping caches.
6. **India Region (`asia-south1` - Mumbai)**: All regional compute, Firestore, Cloud Functions, and Cloud Storage resources reside in Mumbai for minimum latency for India-based users.
7. **Custom Firestore Database Instances**:
   - Dev: `pcn-dev` (with deletion protection enabled)
   - Prod: `pcn-prod` (with deletion protection enabled)
8. **Maximum Terraform Coverage**: Aside from the one-time project bootstrap, all APIs, Firebase settings, Auth providers (with mandatory Google Sign-In), database instances, storage buckets, and application service accounts are provisioned and tracked by Terraform.

---

## Environment Setup Guides

Detailed, copy-paste ready bootstrap and operational instructions are maintained in dedicated guides for each environment:

- **[Development Environment Setup Guide](docs/dev.md)**
- **[Production Environment Setup Guide](docs/prod.md)**

---

## Division of Responsibilities

| Responsibility Area | Handled By | Details |
| :--- | :--- | :--- |
| **GCP Projects & State** | **This Repo (Terraform)** | Project setup, GCS state buckets, service account permissions |
| **GCP & Firebase APIs** | **This Repo (Terraform)** | Enables all 15 services (Firestore, Auth, Calendar, Functions, Build, Run, etc.) |
| **Database & Storage** | **This Repo (Terraform)** | Provisions Firestore (`pcn-dev` / `pcn-prod`) with deletion protection and Firebase Storage bucket |
| **Authentication** | **This Repo (Terraform)** | Identity Platform with Google OAuth Sign-In only (Email, Phone, Anonymous disabled) |
| **Web App Registration** | **This Repo (Terraform)** | Registers Firebase Web App |
| **Security Rules** | **[App Repo](https://github.com/premkumar-masilamani/peer-coaching-network)** (Firebase CLI) | `firestore.rules` and `storage.rules` deployed via `firebase deploy --only firestore:rules,storage` |
| **Cloud Functions** | **[App Repo](https://github.com/premkumar-masilamani/peer-coaching-network)** (Firebase CLI) | Function source code and deployment via `firebase deploy --only functions` |
| **Frontend Web App** | **[App Repo](https://github.com/premkumar-masilamani/peer-coaching-network)** (Firebase CLI) | Application build and hosting via `firebase deploy --only hosting` |

---

## Prerequisites

Before starting, ensure you have the following installed on your machine:

1. **[Google Cloud CLI (`gcloud` / `gsutil`)](https://cloud.google.com/sdk/docs/install)**
2. **[Terraform](https://developer.hashicorp.com/terraform/downloads)** (>= 1.5.0)
3. **[Make](https://www.gnu.org/software/make/)**
4. An active **GCP Billing Account**: `018509-815E33-AA145A` (Verify via `gcloud billing accounts list`)

---

## Common Makefile Commands

The root [`Makefile`](Makefile) provides simple targets with built-in credential pre-flights and isolated data directories.

```bash
# === Development ===
make dev-init       # Initialize Dev backend and provider plugins (.terraform.dev)
make dev-plan       # Preview changes for Dev
make dev-apply      # Apply changes to Dev (human operator only)
make dev-output     # View safe Terraform outputs for Dev
make dev-destroy    # Destroy Dev infrastructure

# === Production ===
make prod-init      # Initialize Prod backend and provider plugins (.terraform.prod)
make prod-plan      # Preview changes for Prod
make prod-apply     # Apply changes to Prod (human operator only)
make prod-output    # View safe Terraform outputs for Prod
make prod-destroy   # Destroy Prod infrastructure

# === Utilities ===
make fmt            # Format all Terraform configuration files
make clean          # Clean local .terraform caches and lockfiles
```

---

## Security Best Practices

1. **Keep `.keys/` Git-Ignored**: All service account keys and OAuth secret JSON files are stored in `terraform/environments/<env>/.keys/` which is strictly ignored by `.gitignore`. Never commit credentials to version control.
2. **Offline Credential Hand-off**: For production or new developer onboarding, team leads can simply share the specific environment's `.keys/` folder through an offline/secure channel.
3. **Environment Isolation via `TF_DATA_DIR`**: The Makefile automatically isolates Dev and Prod into independent data caches (`.terraform.dev` and `.terraform.prod`). Once initialized with `make dev-init` and `make prod-init`, you can run `dev` and `prod` commands interchangeably without needing to re-initialize or clean caches.
