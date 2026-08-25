output "firebase_project_id" {
  description = "The Firebase project ID"
  value       = google_firebase_project.firebase.project
}

output "firestore_database_name" {
  description = "The Firestore database name"
  value       = google_firestore_database.database.name
}

output "firestore_database_location" {
  description = "The Firestore database location"
  value       = google_firestore_database.database.location_id
}

output "firebase_web_app_id" {
  description = "Firebase Web App ID"
  value       = google_firebase_web_app.web_app.app_id
}

output "firebase_web_app_config" {
  description = "Firebase Web App Client SDK Configuration"
  sensitive   = true
  value = {
    api_key             = data.google_firebase_web_app_config.web_app_config.api_key
    auth_domain         = data.google_firebase_web_app_config.web_app_config.auth_domain
    project_id          = var.project_id
    storage_bucket      = google_storage_bucket.app_storage.name
    messaging_sender_id = data.google_firebase_web_app_config.web_app_config.messaging_sender_id
    app_id              = google_firebase_web_app.web_app.app_id
  }
}

output "app_storage_bucket_name" {
  description = "Application storage bucket name"
  value       = google_storage_bucket.app_storage.name
}
