resource "aws_lb_target_group" "load_balancer_target_group" {
  name = "tg-${var.component}-${var.deployment_identifier}"
  port = "${var.target_group_port}"
  target_type = "${var.target_group_type}"
  protocol = "${var.target_group_protocol}"
  vpc_id = "${var.vpc_id}"

//  health_check{
//    enabled = "${var.health_check_enabled}"
//    interval = "${var.health_check_interval}"
//    port ="${var.health_check_port}"
//    protocol ="${var.health_check_protocol}"
//    timeout ="${var.health_check_timeout}"
//    healthy_threshold ="${var.health_check_healthy_threshold}"
//    unhealthy_threshold= "${var.health_check_unhealthy_threshold}"
//  }

  tags {
    Name = "tg-${var.component}-${var.deployment_identifier}"
    Component = "${var.component}"
    DeploymentIdentifier = "${var.deployment_identifier}"
  }
}

//resource "aws_lb_listener" "load_balancer_listener" {
//  load_balancer_arn = "${aws_lb.load_balancer.arn}"
//  port              = "${var.listener_port}"
//  protocol          = "${var.listener_protocol}}"
//
//  ssl_policy        = "ELBSecurityPolicy-2016-08"
//  certificate_arn   = "${var.listener_certificate_arn}}"
//
//  default_action {
//    type             = "forward"
//    target_group_arn = "${aws_lb_target_group.load_balancer_target_group.arn}"
//  }
//}

