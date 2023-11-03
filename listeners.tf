resource "aws_lb_listener" "listener" {
  for_each = local.listeners

  load_balancer_arn = aws_lb.load_balancer.arn

  port = each.value.port
  protocol = each.value.protocol

  ssl_policy = each.value.ssl_policy
  certificate_arn = each.value.certificate_arn

  default_action {
    type = each.value.default_action.type
    target_group_arn = aws_lb_target_group.target_group[each.value.default_action.target_group_key].arn
  }
}
