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

# 2. Firestore Database (Custom Named Instance in Native Mode with Deletion Protection)
resource "google_firestore_database" "database" {
  provider                = google-beta
  project                 = var.project_id
  name                    = var.firestore_database_id
  location_id             = var.firebase_location
  type                    = "FIRESTORE_NATIVE"
  concurrency_mode        = "OPTIMISTIC"
  delete_protection_state = "DELETE_PROTECTION_ENABLED"
  deletion_policy         = "ABANDON"

  depends_on = [google_firebase_project.firebase]
}

# 3. Firebase Web App Registration
resource "google_firebase_web_app" "web_app" {
  provider     = google-beta
  project      = var.project_id
  display_name = "Peer Coaching Network Web (${var.environment})"

  depends_on = [google_firebase_project.firebase]
}

# 4. Firebase Application Cloud Storage Bucket
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

# 5. Firebase Hosting Custom Domain(s)
resource "google_firebase_hosting_custom_domain" "custom_domains" {
  provider = google-beta
  for_each = toset(var.hosting_custom_domains)

  project               = var.project_id
  site_id               = var.project_id
  custom_domain         = each.key
  wait_dns_verification = false

  depends_on = [google_firebase_project.firebase]
}
