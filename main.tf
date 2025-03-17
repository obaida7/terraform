provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name               = cluster1
  location           = var.region
  remove_default_node_pool = true
  initial_node_count = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "node-pool"
  cluster    = google_container_cluster.primary.id
  location   = var.region
  node_count = 2

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 40
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_project_iam_member" "github_actions_compute_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:github-actions@synthetic-grail-448520-b0.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "github_actions_container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:github-actions@synthetic-grail-448520-b0.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/compute.admin",
    "roles/container.admin",
    "roles/compute.instanceAdmin.v1"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${var.github_actions_sa}"
}

resource "google_project_service" "enable_services" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com"
  ])

  project = var.project_id
  service = each.key
}

terraform {
  backend "gcs" {
    bucket = "my-terraform-state-bucket-gke"
    prefix = "gke-cluster/terraform.tfstate"
  }
}
