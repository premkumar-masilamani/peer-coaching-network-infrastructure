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

output "hosting_custom_domains" {
  description = "Custom domains connected to Firebase Hosting"
  value       = [for d in google_firebase_hosting_custom_domain.custom_domains : d.custom_domain]
}

output "app_hosting_site_id" {
  description = "Firebase Hosting site ID for the Web App"
  value       = length(google_firebase_hosting_site.app_site) > 0 ? google_firebase_hosting_site.app_site[0].site_id : null
}

output "landing_hosting_site_id" {
  description = "Firebase Hosting site ID for the Landing Page"
  value       = length(google_firebase_hosting_site.landing_site) > 0 ? google_firebase_hosting_site.landing_site[0].site_id : null
}

output "app_custom_domain" {
  description = "Custom domain for Web App Hosting"
  value       = length(google_firebase_hosting_custom_domain.app_custom_domain) > 0 ? google_firebase_hosting_custom_domain.app_custom_domain[0].custom_domain : null
}

output "landing_custom_domain" {
  description = "Custom domain for Landing Page Hosting"
  value       = length(google_firebase_hosting_custom_domain.landing_custom_domain) > 0 ? google_firebase_hosting_custom_domain.landing_custom_domain[0].custom_domain : null
}

