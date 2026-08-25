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

output "app_storage_bucket_name" {
  description = "Application storage bucket name"
  value       = google_storage_bucket.app_storage.name
}
