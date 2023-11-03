resource "aws_route53_record" "load_balancer" {
  for_each = local.dns.records

  zone_id = each.value.zone_id
  name = "${var.component}-${var.deployment_identifier}.${local.dns.domain_name}"
  type = "A"

  alias {
    name = aws_lb.load_balancer.dns_name
    zone_id = aws_lb.load_balancer.zone_id
    evaluate_target_health = false
  }
}
