module "gke_cluster" {
  source                 = "terraform-google-modules/kubernetes-engine/google"
  version                = "~> 12.1.0"
  project_id             = var.project
  name                   = var.cluster_name
  regional               = true
  region                 = var.region
  network                = var.network
  subnetwork             = var.subnetwork
  ip_range_pods          = join("-", [var.region, "pod-range"])
  ip_range_services      = join("-", [var.region, "service-range"])
  create_service_account = true
}

# connect GKE clusters to Anthos hub
module "gke_hub" {
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/hub"
  version                 = "12.1.0"
  project_id              = var.project
  location                = module.gke_us.location
  cluster_name            = module.gke_cluster.name
  cluster_endpoint        = module.gke_cluster.endpoint
  gke_hub_membership_name = module.gke_cluster.name
  use_existing_sa         = true
  gke_hub_sa_name         = var.service_account_name
  sa_private_key          = base64encode(lookup(var.service_account_key, "rendered", ""))
}