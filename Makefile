.PHONY: help clean fmt dev-init dev-plan dev-apply dev-output dev-destroy prod-init prod-plan prod-apply prod-output prod-destroy check-dev-keys check-prod-keys

# Key file paths per environment
DEV_SA_KEY     ?= $(CURDIR)/terraform/.keys/dev-gcp-sa-key.json
DEV_OAUTH_KEY  ?= $(CURDIR)/terraform/.keys/dev-gcp-oauth-client-secret.json
PROD_SA_KEY    ?= $(CURDIR)/terraform/.keys/prod-gcp-sa-key.json
PROD_OAUTH_KEY ?= $(CURDIR)/terraform/.keys/prod-gcp-oauth-client-secret.json

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
	@echo "  make dev-output   - View outputs (Web App ID, SA emails) for dev"
	@echo "  make dev-destroy  - Destroy dev infrastructure"
	@echo ""
	@echo "Production Environment:"
	@echo "  make prod-init    - Initialize Terraform for prod environment"
	@echo "  make prod-plan    - Preview changes for prod environment"
	@echo "  make prod-apply   - Apply changes to prod environment"
	@echo "  make prod-output  - View outputs (Web App ID, SA emails) for prod"
	@echo "  make prod-destroy - Destroy prod infrastructure"
	@echo ""
	@echo "Utilities:"
	@echo "  make fmt          - Format all Terraform files"
	@echo "  make clean        - Remove local .terraform cache and state locks"

# Pre-flight check to ensure required credentials exist
check-dev-keys:
	@if [ ! -f "$(DEV_SA_KEY)" ]; then \
		echo "ERROR: Service account key not found at $(DEV_SA_KEY)"; \
		echo "Please obtain the environment-specific credential files offline from the team leads and place them in terraform/.keys/"; \
		exit 1; \
	fi
	@if [ ! -f "$(DEV_OAUTH_KEY)" ]; then \
		echo "ERROR: OAuth client secret JSON not found at $(DEV_OAUTH_KEY)"; \
		echo "Please obtain the environment-specific credential files offline from the team leads and place them in terraform/.keys/"; \
		exit 1; \
	fi

check-prod-keys:
	@if [ ! -f "$(PROD_SA_KEY)" ]; then \
		echo "ERROR: Service account key not found at $(PROD_SA_KEY)"; \
		echo "Please obtain the environment-specific credential files offline from the team leads and place them in terraform/.keys/"; \
		exit 1; \
	fi
	@if [ ! -f "$(PROD_OAUTH_KEY)" ]; then \
		echo "ERROR: OAuth client secret JSON not found at $(PROD_OAUTH_KEY)"; \
		echo "Please obtain the environment-specific credential files offline from the team leads and place them in terraform/.keys/"; \
		exit 1; \
	fi

# Clean local terraform cache
clean:
	@echo "Cleaning local terraform cache..."
	@rm -rf terraform/.terraform terraform/.terraform.lock.hcl

# Format terraform code
fmt:
	@echo "Formatting terraform code..."
	@terraform fmt -recursive terraform/

# === DEV ENVIRONMENT ===
dev-init: clean check-dev-keys
	@echo "Initializing Dev Environment with GCS backend..."
	@$(DEV_ENV_VARS) cd terraform && terraform init -backend-config=environments/dev/backend.conf -reconfigure

dev-plan: check-dev-keys
	@echo "Planning Dev Environment..."
	@$(DEV_ENV_VARS) cd terraform && terraform plan -var-file=environments/dev/terraform.tfvars

dev-apply: check-dev-keys
	@echo "Applying Dev Environment..."
	@$(DEV_ENV_VARS) cd terraform && terraform apply -var-file=environments/dev/terraform.tfvars

dev-output: check-dev-keys
	@echo "Fetching Dev Outputs..."
	@$(DEV_ENV_VARS) cd terraform && terraform output

dev-destroy: check-dev-keys
	@echo "Destroying Dev Environment..."
	@$(DEV_ENV_VARS) cd terraform && terraform destroy -var-file=environments/dev/terraform.tfvars

# === PROD ENVIRONMENT ===
prod-init: clean check-prod-keys
	@echo "Initializing Prod Environment with GCS backend..."
	@$(PROD_ENV_VARS) cd terraform && terraform init -backend-config=environments/prod/backend.conf -reconfigure

prod-plan: check-prod-keys
	@echo "Planning Prod Environment..."
	@$(PROD_ENV_VARS) cd terraform && terraform plan -var-file=environments/prod/terraform.tfvars

prod-apply: check-prod-keys
	@echo "Applying Prod Environment..."
	@$(PROD_ENV_VARS) cd terraform && terraform apply -var-file=environments/prod/terraform.tfvars

prod-output: check-prod-keys
	@echo "Fetching Prod Outputs..."
	@$(PROD_ENV_VARS) cd terraform && terraform output

prod-destroy: check-prod-keys
	@echo "Destroying Prod Environment..."
	@$(PROD_ENV_VARS) cd terraform && terraform destroy -var-file=environments/prod/terraform.tfvars
