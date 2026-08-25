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

variable "firestore_delete_protection" {
  type        = bool
  description = "Whether to protect the Firestore database from deletion"
  default     = false
}
