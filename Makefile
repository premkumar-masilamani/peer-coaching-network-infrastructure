.PHONY: help clean fmt dev-init dev-plan dev-apply dev-output dev-config dev-destroy prod-init prod-plan prod-apply prod-output prod-config prod-destroy

# Service Account Keys per environment
DEV_SA_KEY  ?= $(CURDIR)/terraform/.keys/dev-gcp-sa-key.json
PROD_SA_KEY ?= $(CURDIR)/terraform/.keys/prod-gcp-sa-key.json

# Isolate execution from local ambient gcloud state
DEV_ENV_VARS  = GOOGLE_APPLICATION_CREDENTIALS="$(DEV_SA_KEY)" CLOUDSDK_CORE_PROJECT="" CLOUDSDK_BILLING_QUOTA_PROJECT=""
PROD_ENV_VARS = GOOGLE_APPLICATION_CREDENTIALS="$(PROD_SA_KEY)" CLOUDSDK_CORE_PROJECT="" CLOUDSDK_BILLING_QUOTA_PROJECT=""

help:
	@echo "Peer Coaching Network - Infrastructure Commands"
	@echo "================================================"
	@echo "Development Environment:"
	@echo "  make dev-init     - Initialize Terraform for dev environment"
	@echo "  make dev-plan     - Preview changes for dev environment"
	@echo "  make dev-apply    - Apply changes to dev environment"
	@echo "  make dev-output   - View outputs (Web SDK config, SA emails) for dev"
	@echo "  make dev-config   - Export Firebase Web SDK config to .keys/dev-firebase-web-app-config.json"
	@echo "  make dev-destroy  - Destroy dev infrastructure"
	@echo ""
	@echo "Production Environment:"
	@echo "  make prod-init    - Initialize Terraform for prod environment"
	@echo "  make prod-plan    - Preview changes for prod environment"
	@echo "  make prod-apply   - Apply changes to prod environment"
	@echo "  make prod-output  - View outputs (Web SDK config, SA emails) for prod"
	@echo "  make prod-config  - Export Firebase Web SDK config to .keys/prod-firebase-web-app-config.json"
	@echo "  make prod-destroy - Destroy prod infrastructure"
	@echo ""
	@echo "Utilities:"
	@echo "  make fmt          - Format all Terraform files"
	@echo "  make clean        - Remove local .terraform cache and state locks"

# Clean local terraform cache
clean:
	@echo "Cleaning local terraform cache..."
	@rm -rf terraform/.terraform terraform/.terraform.lock.hcl

# Format terraform code
fmt:
	@echo "Formatting terraform code..."
	@terraform fmt -recursive terraform/

# === DEV ENVIRONMENT ===
dev-init: clean
	@echo "Initializing Dev Environment with GCS backend..."
	@$(DEV_ENV_VARS) cd terraform && terraform init -backend-config=environments/dev/backend.conf -reconfigure

dev-plan:
	@echo "Planning Dev Environment..."
	@$(DEV_ENV_VARS) cd terraform && terraform plan -var-file=environments/dev/terraform.tfvars

dev-apply:
	@echo "Applying Dev Environment..."
	@$(DEV_ENV_VARS) cd terraform && terraform apply -var-file=environments/dev/terraform.tfvars

dev-output:
	@echo "Fetching Dev Outputs..."
	@$(DEV_ENV_VARS) cd terraform && terraform output

dev-config:
	@echo "Exporting Dev Firebase Web SDK config to terraform/.keys/dev-firebase-web-app-config.json..."
	@$(DEV_ENV_VARS) cd terraform && terraform output -json firebase_web_app_config > .keys/dev-firebase-web-app-config.json
	@echo "Saved to terraform/.keys/dev-firebase-web-app-config.json"

dev-destroy:
	@echo "Destroying Dev Environment..."
	@$(DEV_ENV_VARS) cd terraform && terraform destroy -var-file=environments/dev/terraform.tfvars

# === PROD ENVIRONMENT ===
prod-init: clean
	@echo "Initializing Prod Environment with GCS backend..."
	@$(PROD_ENV_VARS) cd terraform && terraform init -backend-config=environments/prod/backend.conf -reconfigure

prod-plan:
	@echo "Planning Prod Environment..."
	@$(PROD_ENV_VARS) cd terraform && terraform plan -var-file=environments/prod/terraform.tfvars

prod-apply:
	@echo "Applying Prod Environment..."
	@$(PROD_ENV_VARS) cd terraform && terraform apply -var-file=environments/prod/terraform.tfvars

prod-output:
	@echo "Fetching Prod Outputs..."
	@$(PROD_ENV_VARS) cd terraform && terraform output

prod-config:
	@echo "Exporting Prod Firebase Web SDK config to terraform/.keys/prod-firebase-web-app-config.json..."
	@$(PROD_ENV_VARS) cd terraform && terraform output -json firebase_web_app_config > .keys/prod-firebase-web-app-config.json
	@echo "Saved to terraform/.keys/prod-firebase-web-app-config.json"

prod-destroy:
	@echo "Destroying Prod Environment..."
	@$(PROD_ENV_VARS) cd terraform && terraform destroy -var-file=environments/prod/terraform.tfvars
