variable "region" {}
variable "availability_zones" {
  type = list(string)
}
variable "vpc_cidr" {}

variable "component" {}
variable "deployment_identifier" {}

variable "domain_name" {}
variable "public_zone_id" {}
variable "private_zone_id" {}

variable "access_logs_bucket_name" {}
variable "access_logs_bucket_prefix" {}
