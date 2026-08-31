variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project"
}

variable "environment" {
  type        = string
  description = "Environment name (dev or prod)"
}

variable "firebase_location" {
  type        = string
  description = "The location for Firestore database and storage (e.g., asia-south1)"
  default     = "asia-south1"
}

variable "firestore_database_id" {
  type        = string
  description = "The ID of the Firestore database (e.g. pcn-dev or pcn-prod)"
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

