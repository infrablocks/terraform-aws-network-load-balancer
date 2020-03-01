variable "region" {}
variable "vpc_cidr" {}
variable "availability_zones" {
  type = list(string)
}

variable "component" {}
variable "deployment_identifier" {}

variable "public_zone_id" {}
variable "private_zone_id" {}

variable "domain_name" {}
