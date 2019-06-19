output "name" {
  description = "The name of the created NLB."
  value = "${aws_lb.load_balancer.name}"
}

output "id" {
  description = "The id of the created NLB."
  value = "${aws_lb.load_balancer.id}"

}

output "arn" {
  description = "The arn of the created NLB."
  value = "${aws_lb.load_balancer.arn}"
}

output "arn_suffix" {
  description = "The arn suffix of the created NLB."
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
