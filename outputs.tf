output "name" {
  description = "The name of the created NLB."
  value = "${aws_lb.load_balancer.name}"
}

output "id" {
  description = "The id of the created NLB."
  value = "${aws_lb.load_balancer.id}"
}

output "arn" {
  description = "The ARN of the created NLB."
  value = "${aws_lb.load_balancer.arn}"
}

output "arn_suffix" {
  description = "The ARN suffix of the created NLB."
  value = "${aws_lb.load_balancer.arn_suffix}"
}

output "zone_id" {
  description = "The zone ID of the created NLB."
  value = "${aws_lb.load_balancer.zone_id}"
}

output "dns_name" {
  description = "The DNS name of the created NLB."
  value = "${aws_lb.load_balancer.dns_name}"
}

output "address" {
  description = "The address of the DNS record(s) for the created NLB."
  value = "${var.component}-${var.deployment_identifier}.${var.domain_name}"
}

output "target_group_id" {
  description = "The id of the target group"
  value = "${aws_lb_target_group.load_balancer_target_group.id}"
}

output "target_group_arn" {
  description = "The arn of the target group"
  value = "${aws_lb_target_group.load_balancer_target_group.arn}"
}

output "target_group_arn_suffix" {
  description = "The arn_suffix of the target group"
  value = "${aws_lb_target_group.load_balancer_target_group.arn_suffix}"
}

output "target_group_name" {
  description = "The name of the target group"
  value = "${aws_lb_target_group.load_balancer_target_group.name}"
}
