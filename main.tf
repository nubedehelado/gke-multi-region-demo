locals {
  us_subnet = "us-subnet"
  eu_subnet = "eu-subnet"
}

# enable required APIs in project
resource "google_project_service" "compute_engine_api" {
  service = "compute.googleapis.com"
}
resource "google_project_service" "gkehub_api" {
  service            = "gkehub.googleapis.com"
  disable_on_destroy = true
}
resource "google_project_service" "anthos_api" {
  service            = "anthos.googleapis.com"
  disable_on_destroy = true
}
resource "google_project_service" "multiclusteringress_api" {
  service            = "multiclusteringress.googleapis.com"
  disable_on_destroy = true
}

module "network" {

  source = "modules/network"

  depends_on = [
    google_project_service.compute_engine_api,
    google_project_service.anthos_api,
    google_project_service.gkehub_api,
    google_project_service.multiclusteringress_api
  ]
  project        = var.project
  region1        = var.region1
  region1_subnet = local.us_subnet
  region2        = var.region2
  region2_subnet = local.eu_subnet
}

module "service_account" {
  source               = "modules/iam"
  service_account_name = "gke-hub"
}

module "gke_us" {

  source = "modules/gke"

  cluster_name         = "gke-us"
  network              = module.network.name
  project              = var.project
  region               = var.region1
  subnetwork           = local.us_subnet
  service_account_key  = module.service_account.key
  service_account_name = module.service_account.name
}

module "gke_eu" {

  source = "modules/gke"

  cluster_name         = "gke-eu"
  network              = module.network.name
  project              = var.project
  region               = var.region2
  subnetwork           = local.eu_subnet
  service_account_key  = module.service_account.key
  service_account_name = module.service_account.name

}