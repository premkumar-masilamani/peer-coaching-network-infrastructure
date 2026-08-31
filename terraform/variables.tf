variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud environment project (e.g. pcn-dev-506605 or pcn-prod)"
}

variable "environment" {
  type        = string
  description = "Environment name (dev or prod)"
}

variable "region" {
  type        = string
  description = "The default GCP region for regional resources (Compute, Storage, Functions)"
  default     = "asia-south1"
}

variable "firebase_location" {
  type        = string
  description = "The location for Firestore database and Firebase services (e.g., asia-south1 for Mumbai)"
  default     = "asia-south1"
}

variable "firestore_database_id" {
  type        = string
  description = "The ID of the Firestore database instance (e.g., pcn-dev or pcn-prod)"
}

variable "authorized_domains" {
  type        = list(string)
  description = "Authorized domains for Firebase Authentication"
  default     = ["localhost"]
}

variable "oauth_client_secret_file" {
  type        = string
  description = "Path to the downloaded OAuth 2.0 Client Secret JSON file (e.g. environments/dev/.keys/dev-gcp-oauth-client-secret.json)"
}


variable "landing_hosting_site_id" {
  type        = string
  description = "Site ID for the Landing Page Firebase Hosting site"
  default     = ""
}

variable "app_custom_domain" {
  type        = string
  description = "Custom domain for the Web App Hosting site"
  default     = ""
}

variable "landing_custom_domain" {
  type        = string
  description = "Custom domain for the Landing Page Hosting site"
  default     = ""
}

