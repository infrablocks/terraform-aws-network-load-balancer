resource "aws_lb" "load_balancer" {
  load_balancer_type = "network"

  subnets = var.subnet_ids

  internal = var.expose_to_public_internet ? false : true

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing ? true : false

  tags = {
    Name = "nlb-${var.component}-${var.deployment_identifier}"
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
  }
}
