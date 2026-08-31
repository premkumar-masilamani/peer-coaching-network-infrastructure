output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "app_service_account_email" {
  description = "The application service account email for runtime / Cloud Functions"
  value       = module.google_core.app_service_account_email
}

output "firestore_database_name" {
  description = "The name of the Firestore database instance"
  value       = module.firebase.firestore_database_name
}

output "firestore_database_location" {
  description = "The location of the Firestore database"
  value       = module.firebase.firestore_database_location
}

output "app_storage_bucket" {
  description = "The GCS bucket for Firebase application storage"
  value       = module.firebase.app_storage_bucket_name
}

output "firebase_web_app_id" {
  description = "Firebase Web App ID"
  value       = module.firebase.firebase_web_app_id
}

output "authorized_domains" {
  description = "Authorized domains configured for Firebase Authentication / Identity Platform"
  value       = module.google_core.authorized_domains
}

output "app_hosting_site_id" {
  description = "Firebase Hosting site ID for the Web App"
  value       = module.firebase.app_hosting_site_id
}

output "landing_hosting_site_id" {
  description = "Firebase Hosting site ID for the Landing Page"
  value       = module.firebase.landing_hosting_site_id
}

output "app_custom_domain" {
  description = "Custom domain for Web App Hosting"
  value       = module.firebase.app_custom_domain
}

output "landing_custom_domain" {
  description = "Custom domain for Landing Page Hosting"
  value       = module.firebase.landing_custom_domain
}

output "enabled_services" {
  description = "List of GCP and Firebase APIs enabled by Terraform"
  value       = module.google_core.enabled_services
}


