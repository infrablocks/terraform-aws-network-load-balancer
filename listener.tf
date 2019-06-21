resource "aws_lb_listener" "load_balancer_listener" {
  load_balancer_arn = "${aws_lb.load_balancer.arn}"
  port              = "${var.listener_port}"
  protocol          = "${var.listener_protocol}"

  //  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${var.listener_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.load_balancer_target_group.arn}"
  }
}
