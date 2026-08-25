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

# 1. Add Firebase Services to Google Cloud Project
resource "google_firebase_project" "firebase" {
  provider = google-beta
  project  = var.project_id
}

# 2. Firestore Database (Custom Named Instance in Native Mode)
resource "google_firestore_database" "database" {
  provider                = google-beta
  project                 = var.project_id
  name                    = var.firestore_database_id
  location_id             = var.firebase_location
  type                    = "FIRESTORE_NATIVE"
  concurrency_mode        = "OPTIMISTIC"
  delete_protection_state = var.firestore_delete_protection ? "DELETE_PROTECTION_ENABLED" : "DELETE_PROTECTION_DISABLED"
  deletion_policy         = var.firestore_delete_protection ? "ABANDON" : "DELETE"

  depends_on = [google_firebase_project.firebase]
}

# 3. Firebase Web App Registration
resource "google_firebase_web_app" "web_app" {
  provider     = google-beta
  project      = var.project_id
  display_name = "Peer Coaching Network Web (${var.environment})"

  depends_on = [google_firebase_project.firebase]
}

# 4. Data Source for Firebase Web App Config (SDK credentials)
data "google_firebase_web_app_config" "web_app_config" {
  provider   = google-beta
  project    = var.project_id
  web_app_id = google_firebase_web_app.web_app.app_id

  depends_on = [google_firebase_web_app.web_app]
}

# 5. Firebase Application Cloud Storage Bucket
resource "google_storage_bucket" "app_storage" {
  provider                    = google-beta
  project                     = var.project_id
  name                        = "${var.project_id}-app-storage"
  location                    = var.firebase_location
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "POST", "PUT", "DELETE", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  depends_on = [google_firebase_project.firebase]
}
