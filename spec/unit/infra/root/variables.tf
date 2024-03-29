variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "enable_cross_zone_load_balancing" {
  type = bool
  default = null
}

variable "expose_to_public_internet" {
  type = bool
  default = null
}

variable "dns" {
  type = object({
    domain_name: string,
    records: optional(list(object({zone_id: string})))
  })
  default = null
}

variable "target_groups" {
  type = list(object({
    key: string,
    port: string,
    protocol: string,
    target_type: optional(string),
    deregistration_delay: optional(number),
    health_check: optional(object({
      port: optional(string),
      protocol: optional(string),
      interval: optional(number),
      healthy_threshold: optional(number),
      unhealthy_threshold: optional(number)
    }))
  }))
  default = null
}

variable "listeners" {
  type = list(object({
    key: string,
    port: string,
    protocol: string,
    certificate_arn: optional(string),
    ssl_policy: optional(string),
    default_action: object({
      type: string,
      target_group_key: string
    })
  }))
  default = null
}

variable "enable_deletion_protection" {
  default = null
}

variable "enable_access_logs" {
  type    = bool
  default = null
}

variable "access_logs_bucket_name" {
  default = null
}

variable "access_logs_bucket_prefix" {
  default = null
}
