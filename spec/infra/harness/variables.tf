variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "domain_name" {}
variable "public_zone_id" {}
variable "private_zone_id" {}

variable "enable_cross_zone_load_balancing" {}

variable "idle_timeout" {}

variable "include_public_dns_record" {}
variable "include_private_dns_record" {}

variable "expose_to_public_internet" {}

variable "use_https" {}
variable "target_group_port" {}
variable "target_group_type" {}
variable "target_group_protocol" {}

variable "health_check_port" {}
variable "health_check_protocol" {}
variable "health_check_timeout" {}
variable "health_check_interval" {}
variable "health_check_unhealthy_threshold" {}
variable "health_check_healthy_threshold" {}


