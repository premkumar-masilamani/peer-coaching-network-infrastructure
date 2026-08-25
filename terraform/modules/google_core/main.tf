terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.0"
    }
  }
}

# 1. Enable Required GCP and Firebase APIs
resource "google_project_service" "services" {
  provider           = google-beta
  for_each           = toset(var.enable_services)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# 2. Firebase Authentication (Identity Platform)
resource "google_identity_platform_config" "auth_config" {
  provider                   = google-beta
  project                    = var.project_id
  autodelete_anonymous_users = false

  sign_in {
    allow_duplicate_emails = false

    email {
      enabled           = true
      password_required = true
    }
  }

  authorized_domains = concat(
    [
      "localhost",
      "${var.project_id}.firebaseapp.com",
      "${var.project_id}.web.app"
    ],
    var.authorized_domains
  )

  depends_on = [google_project_service.services]
}

# 3. Google Sign-In Provider (Identity Platform Default Supported IDP)
resource "google_identity_platform_default_supported_idp_config" "google_sign_in" {
  count         = var.oauth_client_id != "" && var.oauth_client_secret != "" ? 1 : 0
  provider      = google-beta
  project       = var.project_id
  enabled       = true
  idp_id        = "google.com"
  client_id     = var.oauth_client_id
  client_secret = var.oauth_client_secret

  depends_on = [google_identity_platform_config.auth_config]
}

# 4. Application Runtime Service Account (for Cloud Functions / Backend App)
resource "google_service_account" "app_sa" {
  provider     = google-beta
  project      = var.project_id
  account_id   = "pcn-app-${var.environment}"
  display_name = "Peer Coaching Network App Service Account (${var.environment})"

  depends_on = [google_project_service.services]
}

# 5. IAM Roles for Application Service Account
resource "google_project_iam_member" "app_sa_firestore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}

resource "google_project_iam_member" "app_sa_firebase_auth_admin" {
  project = var.project_id
  role    = "roles/firebaseauth.admin"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}

resource "google_project_iam_member" "app_sa_storage_user" {
  project = var.project_id
  role    = "roles/storage.objectUser"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}
