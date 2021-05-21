# create a VPC network with a subnet in one US and EU GCP region
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.5"

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