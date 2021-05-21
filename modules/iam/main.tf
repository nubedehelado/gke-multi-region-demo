# create service account allowing clusters to connect to GKE Hub
module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 3.0"
  project_id    = var.project
  names         = [var.service_account_name]
  description   = "Service Account to connect K8s clusters to GKE Hub"
  generate_keys = "true"
  project_roles = [
    join("=>", [var.project, "roles/gkehub.connect"]),
  ]
}