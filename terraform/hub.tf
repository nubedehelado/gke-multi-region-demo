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

# connect GKE clusters to Anthos hub
module "hub_us" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/hub"
  version          = "12.1.0"
  project_id       = var.project
  location         = module.gke_us.location
  cluster_name     = module.gke_us.name
  cluster_endpoint = module.gke_us.endpoint
  gke_hub_membership_name = module.gke_us.name
  use_existing_sa  = true
  gke_hub_sa_name  = var.service_account_name
  sa_private_key   = base64encode(lookup(module.service_accounts.key, "rendered", ""))
}

module "hub_eu" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/hub"
  version          = "12.1.0"
  project_id       = var.project
  location         = module.gke_eu.location
  cluster_name     = module.gke_eu.name
  cluster_endpoint = module.gke_eu.endpoint
  gke_hub_membership_name = module.gke_eu.name
  use_existing_sa  = true
  gke_hub_sa_name  = var.service_account_name
  sa_private_key   = base64encode(lookup(module.service_accounts.key, "rendered", ""))
}