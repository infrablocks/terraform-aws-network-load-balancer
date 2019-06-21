variable "region" {
  description = "The region into which to deploy the load balancer."
}

variable "vpc_id" {
  description = "The ID of the VPC into which to deploy the load balancer."
}

variable "subnet_ids" {
  description = "The IDs of the subnets for the NLB."
  type        = "list"
}

variable "domain_name" {
  description = "The domain name of the supplied Route 53 zones."
}

variable "public_zone_id" {
  description = "The ID of the public Route 53 zone."
}

variable "private_zone_id" {
  description = "The ID of the private Route 53 zone."
}

variable "component" {
  description = "The component for which the load balancer is being created."
}

variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "enable_cross_zone_load_balancing" {
  description = "Whether or not to enable cross zone load balancing (\"yes\" or \"no\")."
  default     = "no"
}

variable "idle_timeout" {
  description = "The time after which idle connections are closed."
  default     = 60
}

variable "include_public_dns_record" {
  description = "Whether or not to create a public DNS entry (\"yes\" or \"no\")."
  default     = "no"
}

variable "include_private_dns_record" {
  description = "Whether or not to create a private DNS entry (\"yes\" or \"no\")."
  default     = "yes"
}

variable "expose_to_public_internet" {
  description = "Whether or not to the NLB should be internet facing (\"yes\" or \"no\")."
  default     = "no"
}

variable "use_https" {
  description = "wheter or not to use HTTPS"
  default     = false
}

variable "target_group_port" {
  description = "wheter or not to enable NLB healthcheck"
  default     = true
}

variable "target_group_type" {
  description = "The type of target that you must specify when registering targets with this target group. Defaults to instance"
  default     = "instance"
}

variable "target_group_protocol" {
  description = "The protocol to use for routing traffic to the targets. Should be one of TCP, TLS, defaults to TCP"
  default     = "TCP"
}

variable "health_check_port" {
  description = "The port to use to connect with the target. Either ports 1-65536, or traffic-port. Defaults to traffic-port"
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "The protocol to use to connect with the target. Defaults to TCP"
  default     = "TCP"
}

variable "health_check_interval" {
  description = "The time between health check attempts in seconds."
  default     = 30
}

variable "health_check_unhealthy_threshold" {
  description = "The number of failed health checks before an instance is taken out of service."
  default     = 2
}

variable "health_check_healthy_threshold" {
  description = "The number of successful health checks before an instance is put into service."
  default     = 10
}

variable "listener_port" {
  description = "The port on which the load balancer is listening. Defaults to 443"
  default     = 443
}

variable "listener_protocol" {
  description = "The protocol for connections from clients to the load balancer. Either TCP or TLS"
  default     = "TLS"
}

variable "listener_certificate_arn" {
  description = "The ARN of the default SSL server certificate"
}
