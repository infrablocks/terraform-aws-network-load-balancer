resource "aws_lb_target_group" "load_balancer_target_group" {
  name = "tg-${var.component}"
  port = var.target_group_port
  target_type = var.target_group_type
  protocol = var.target_group_protocol
  vpc_id = var.vpc_id

  health_check {
    interval = var.health_check_interval
    port = var.health_check_port
    protocol = var.health_check_protocol
    healthy_threshold = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = {
    Name = "tg-${var.component}-${var.deployment_identifier}"
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
  }
}
