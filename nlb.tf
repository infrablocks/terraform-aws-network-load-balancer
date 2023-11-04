resource "aws_lb" "load_balancer" {
  load_balancer_type = "network"

  subnets = var.subnet_ids

  internal = var.expose_to_public_internet ? false : true

  enable_deletion_protection  = var.enable_deletion_protection

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [0] : []
    content {
      bucket  = var.access_logs_bucket_name
      prefix  = var.access_logs_bucket_prefix
      enabled = var.enable_access_logs
    }
  }

  tags = {
    Name = "nlb-${var.component}-${var.deployment_identifier}"
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
  }
}
