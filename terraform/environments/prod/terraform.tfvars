project_id               = "YOUR_PROD_PROJECT_ID"
environment              = "prod"
region                   = "asia-south1"
firebase_location        = "asia-south1"
firestore_database_id    = "pcn-prod"
oauth_client_secret_file = "environments/prod/.keys/prod-gcp-oauth-client-secret.json"

app_hosting_site_id     = "prod-app"
landing_hosting_site_id = "prod-www"
app_custom_domain       = "app.peercoachingnetwork.com"
landing_custom_domain   = "www.peercoachingnetwork.com"

authorized_domains = [
  "app.peercoachingnetwork.com",
  "peercoachingnetwork.com"
]


