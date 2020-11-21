# create a VPC network with a subnet in one US and EU GCP region
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.5"
  depends_on = [
    google_project_service.compute_engine_api,
    google_project_service.anthos_api,
    google_project_service.gkehub_api,
    google_project_service.multiclusteringress_api
  ]

  project_id   = var.project
  network_name = "gke-net"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "us-subnet"
      subnet_ip     = "10.128.0.0/20"
      subnet_region = var.region1
    },
    {
      subnet_name   = "eu-subnet"
      subnet_ip     = "10.132.0.0/20"
      subnet_region = var.region2
    }
  ]

  secondary_ranges = {
    us-subnet = [
      {
        range_name    = join("-", [var.region1, "service-range"])
        ip_cidr_range = "10.24.0.0/20"
      },
      {
        range_name    = join("-", [var.region1, "pod-range"])
        ip_cidr_range = "10.20.0.0/14"
      }
    ]

    eu-subnet = [
      {
        range_name    = join("-", [var.region2, "service-range"])
        ip_cidr_range = "10.0.0.0/20"
      },
      {
        range_name    = join("-", [var.region2, "pod-range"])
        ip_cidr_range = "10.48.0.0/14"
      }
    ]

  }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}

# deploy a cluster in the US and EU
module "gke_us" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 12.1.0"
  project_id             = var.project
  name                   = "gke-us"
  regional               = true
  region                 = var.region1
  network                = module.vpc.network_name
  subnetwork             = "us-subnet"
  ip_range_pods          = join("-", [var.region1, "pod-range"])
  ip_range_services      = join("-", [var.region1, "service-range"])
  create_service_account = true
}

module "gke_eu" {
  source                 = "terraform-google-modules/kubernetes-engine/google"
  version                = "~> 12.1.0"
  project_id             = var.project
  name                   = "gke-eu"
  regional               = true
  region                 = var.region2
  network                = module.vpc.network_name
  subnetwork             = "eu-subnet"
  ip_range_pods          = join("-", [var.region2, "pod-range"])
  ip_range_services      = join("-", [var.region2, "service-range"])
  create_service_account = true
}
