resource "aws_lb_target_group" "target_group" {
  for_each = local.target_groups

  vpc_id = var.vpc_id

  port = each.value.port
  protocol = each.value.protocol

  target_type = each.value.target_type

  deregistration_delay = each.value.deregistration_delay

  health_check {
    port = each.value.health_check.port
    protocol = each.value.health_check.protocol
    interval = each.value.health_check.interval
    healthy_threshold = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
  }

  tags = {
    Name = "${var.component}-${var.deployment_identifier}-${each.value.port}-${each.value.protocol}"
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
  }

  # this dependency is required to ensure the target group has an LB before it
  # can be used by a dependent
  depends_on = [
    aws_lb.load_balancer
  ]
}
