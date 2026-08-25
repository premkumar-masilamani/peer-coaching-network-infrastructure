variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project"
}

variable "environment" {
  type        = string
  description = "Environment name (dev or prod)"
}

variable "enable_services" {
  type        = list(string)
  description = "GCP and Firebase APIs to enable"
  default = [
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "firebase.googleapis.com",
    "firestore.googleapis.com",
    "identitytoolkit.googleapis.com",
    "firebaserules.googleapis.com",
    "firebasestorage.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "calendar-json.googleapis.com"
  ]
}

variable "authorized_domains" {
  type        = list(string)
  description = "Additional authorized domains for Firebase Authentication"
  default     = []
}

variable "oauth_client_id" {
  type        = string
  description = "OAuth 2.0 Web Client ID for Google Sign-In"
  sensitive   = true
  default     = ""
}

variable "oauth_client_secret" {
  type        = string
  description = "OAuth 2.0 Web Client Secret for Google Sign-In"
  sensitive   = true
  default     = ""
}
