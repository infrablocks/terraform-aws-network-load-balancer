resource "aws_lb" "load_balancer" {
  load_balancer_type = "network"

  subnets = var.subnet_ids
  security_groups = local.security_groups.default.associate == "yes" ? [aws_security_group.default["default"].id] : null

  internal = var.expose_to_public_internet ? false : true

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing ? true : false

  tags = {
    Name = "nlb-${var.component}-${var.deployment_identifier}"
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
  }
}
