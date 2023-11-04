data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "network_load_balancer" {
  source = "../../../.."

  region     = var.region
  vpc_id     = data.terraform_remote_state.prerequisites.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.prerequisites.outputs.subnet_ids

  component             = var.component
  deployment_identifier = var.deployment_identifier

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection = var.enable_deletion_protection

  expose_to_public_internet = var.expose_to_public_internet

  dns           = var.dns
  listeners     = var.listeners
  target_groups = var.target_groups

  enable_access_logs = var.enable_access_logs
  access_logs_bucket_name = var.access_logs_bucket_name
  access_logs_bucket_prefix = var.access_logs_bucket_prefix
}
