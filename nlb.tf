resource "aws_lb" "load_balancer" {
  load_balancer_type = "network"

  name = "nlb-${var.component}"
  subnets = var.subnet_ids

  internal = var.expose_to_public_internet == "yes" ? false : true

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing == "yes" ? true : false

  idle_timeout = var.idle_timeout

  tags = {
    Name = "nlb-${var.component}-${var.deployment_identifier}"
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
  }
}
