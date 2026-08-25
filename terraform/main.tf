locals {
  # Mandatorily read the OAuth client secret JSON file. Terraform will fail fast if the file does not exist.
  oauth_file_path     = "${path.module}/${var.oauth_client_secret_file}"
  oauth_json          = jsondecode(file(local.oauth_file_path))
  oauth_client_id     = try(local.oauth_json.web.client_id, local.oauth_json.installed.client_id)
  oauth_client_secret = try(local.oauth_json.web.client_secret, local.oauth_json.installed.client_secret)
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

  project_id            = var.project_id
  environment           = var.environment
  firebase_location     = var.firebase_location
  firestore_database_id = var.firestore_database_id

  # Ensure google APIs and core infrastructure are ready before adding firebase
  depends_on = [module.google_core]
}
