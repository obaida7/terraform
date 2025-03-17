variable "project_id" {
      default = "synthetic-grail-448520-b0"
}
variable "region" {
  default = "us-central1"
}
variable "cluster_name" {
  default = "cluster1"
}
variable "github_actions_sa" {
  description = "GitHub Actions service account email"
  type        = string
}
variable "disable_dependent_services" {
  description = "Flag to disable dependent services"
  type        = bool
  default     = false  # Default value if not specified
}
