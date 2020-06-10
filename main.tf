# TODO: enable apis

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.3"

  project_id   = var.project
  network_name = "gke-net"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "oregon-subnet"
      subnet_ip     = "10.128.0.0/20"
      subnet_region = var.region1
    },
    {
      subnet_name   = "belgium-subnet"
      subnet_ip     = "10.132.0.0/20"
      subnet_region = var.region2
    }
  ]

  secondary_ranges = {
    oregon-subnet = [
      {
        range_name    = join("-", [var.region1, "service-range"])
        ip_cidr_range = "10.24.0.0/20"
      },
      {
        range_name    = join("-", [var.region1, "pod-range"])
        ip_cidr_range = "10.20.0.0/14"
      }
    ]

    belgium-subnet = [
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

module "gke_us" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project
  name                       = "gke-us"
  region                     = var.region1
  zones                      = [join("-", [var.region1, "a"])]
  network                    = module.vpc.network_name
  subnetwork                 = "oregon-subnet"
  ip_range_pods              = join("-", [var.region1, "pod-range"])
  ip_range_services          = join("-", [var.region1, "service-range"])
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true

  node_pools = [
    {
      name                   = "gke-us-default-node-pool"
      machine_type           = "n1-standard-1"
      min_count              = 1
      max_count              = 10
      disk_size_gb           = 100
      disk_type              = "pd-standard"
      image_type             = "COS"
      auto_repair            = true
      auto_upgrade           = true
      create_service_account = true
      preemptible            = false
      initial_node_count     = 3
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}

module "gke_eu" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project
  name                       = "gke-eu"
  region                     = var.region2
  zones                      = [join("-", [var.region2, "c"])]
  network                    = module.vpc.network_name
  subnetwork                 = "belgium-subnet"
  ip_range_pods              = join("-", [var.region2, "pod-range"])
  ip_range_services          = join("-", [var.region2, "service-range"])
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true

  node_pools = [
    {
      name                   = "gke-eu-default-node-pool"
      machine_type           = "n1-standard-1"
      min_count              = 1
      max_count              = 10
      disk_size_gb           = 100
      disk_type              = "pd-standard"
      image_type             = "COS"
      auto_repair            = true
      auto_upgrade           = true
      create_service_account = true
      preemptible            = false
      initial_node_count     = 3
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}

module "service_accounts" {
  source      = "terraform-google-modules/service-accounts/google"
  version     = "~> 3.0"
  project_id  = var.project
  prefix      = "sa"
  names       = ["gke-hub"]
  description = "Service Account to connect K8s clusters to GKE Hub"
  generate_keys = "true"
  project_roles = [
    join("=>", [var.project, "roles/gkehub.connect"]),
  ]
}
