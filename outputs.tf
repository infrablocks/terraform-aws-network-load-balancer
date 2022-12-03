locals {
  target_groups_output = {
    for target_group in var.target_groups : target_group.key => {
      id         = aws_lb_target_group.target_group[target_group.key].id,
      name       = aws_lb_target_group.target_group[target_group.key].name,
      arn        = aws_lb_target_group.target_group[target_group.key].arn,
      arn_suffix = aws_lb_target_group.target_group[target_group.key].arn_suffix,
    }
  }

  listeners_output = {
    for listener in var.listeners : listener.key => {
      arn             = aws_lb_listener.listener[listener.key].arn,
      certificate_arn = aws_lb_listener.listener[listener.key].certificate_arn
    }
  }
}

output "name" {
  description = "The name of the created NLB."
  value = aws_lb.load_balancer.name
}

output "vpc_id" {
  description = "The VPC ID of the created NLB."
  value = aws_lb.load_balancer.vpc_id
}

output "id" {
  description = "The id of the created NLB."
  value = aws_lb.load_balancer.id
}

output "arn" {
  description = "The ARN of the created NLB."
  value = aws_lb.load_balancer.arn
}

output "arn_suffix" {
  description = "The ARN suffix of the created NLB."
  value = aws_lb.load_balancer.arn_suffix
}

output "zone_id" {
  description = "The zone ID of the created NLB."
  value = aws_lb.load_balancer.zone_id
}

output "dns_name" {
  description = "The DNS name of the created NLB."
  value = aws_lb.load_balancer.dns_name
}

output "address" {
  description = "The address of the DNS record(s) for the created NLB."
  value = length(var.dns.records) > 0 ? "${var.component}-${var.deployment_identifier}.${var.dns.domain_name}" : ""
}

output "target_groups" {
  description = "Details of the created target groups."
  value = local.target_groups_output
}

output "listeners" {
  description = "Details of the created listeners."
  value = local.listeners_output
}
