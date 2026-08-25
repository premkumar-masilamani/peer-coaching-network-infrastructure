locals {
  oauth_file_path = var.oauth_client_secret_file != "" ? "${path.module}/${var.oauth_client_secret_file}" : ""
  has_oauth_file  = local.oauth_file_path != "" ? fileexists(local.oauth_file_path) : false
  oauth_json      = local.has_oauth_file ? jsondecode(file(local.oauth_file_path)) : null

  oauth_client_id = local.has_oauth_file ? (
    try(local.oauth_json.web.client_id, try(local.oauth_json.installed.client_id, ""))
  ) : var.oauth_client_id

  oauth_client_secret = local.has_oauth_file ? (
    try(local.oauth_json.web.client_secret, try(local.oauth_json.installed.client_secret, ""))
  ) : var.oauth_client_secret
}

module "google_core" {
  source = "./modules/google_core"

  project_id          = var.project_id
  environment         = var.environment
  authorized_domains  = var.authorized_domains
  oauth_client_id     = local.oauth_client_id
  oauth_client_secret = local.oauth_client_secret
}

module "firebase" {
  source = "./modules/firebase"

  project_id                  = var.project_id
  environment                 = var.environment
  firebase_location           = var.firebase_location
  firestore_database_id       = var.firestore_database_id
  firestore_delete_protection = var.firestore_delete_protection

  # Ensure google APIs and core infrastructure are ready before adding firebase
  depends_on = [module.google_core]
}
