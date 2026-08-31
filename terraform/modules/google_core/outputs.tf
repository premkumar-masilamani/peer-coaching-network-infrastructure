output "services_ready" {
  description = "Dependency hook to ensure APIs are enabled before downstream modules execute"
  value       = true
  depends_on  = [google_project_service.services]
}

output "app_service_account_email" {
  description = "Email address of the application runtime service account"
  value       = google_service_account.app_sa.email
}

output "identity_platform_config" {
  description = "Identity platform configuration resource"
  value       = google_identity_platform_config.auth_config.name
}

output "authorized_domains" {
  description = "Authorized domains configured in Identity Platform"
  value       = google_identity_platform_config.auth_config.authorized_domains
}


