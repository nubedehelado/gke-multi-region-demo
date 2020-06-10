provider "google" {
  project = var.project
  region  = var.region1
  zone    = join("-", [var.region1, "a"])
}
