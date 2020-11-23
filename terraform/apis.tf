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