variable "region" {
  description = "The region into which to deploy the load balancer."
}

variable "vpc_id" {
  description = "The ID of the VPC into which to deploy the load balancer."
}

variable "subnet_ids" {
  description = "The IDs of the subnets for the NLB."
  type = list(string)
}

variable "component" {
  description = "The component for which the load balancer is being created."
}

variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "enable_cross_zone_load_balancing" {
  description = "Whether or not to enable cross zone load balancing. Defaults to false."
  type = bool
  default = false
  nullable = false
}

variable "expose_to_public_internet" {
  description = "Whether or not to the NLB should be internet facing (\"yes\" or \"no\")."
  type = bool
  default = false
  nullable = false
}

variable "dns" {
  description = "Details of DNS records to point at the created load balancer. Expects a domain_name, used to create each record and a list of records to create. Each record object includes a zone_id referencing the hosted zone in which to create the record."
  type = object({
    domain_name: string,
    records: optional(list(object({zone_id: string})))
  })
  default = {
    domain_name: null,
    records: []
  }
  nullable = false
}

variable "target_groups" {
  description = "Details of target groups to create."
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
    }), {
      port: null,
      protocol: null,
      interval: null,
      healthy_threshold: null,
      unhealthy_threshold: null
    })
  }))
  default = []
  nullable = false
}

variable "listeners" {
  description = "Details of listeners to create."
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
  default = []
  nullable = false
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer."
  default = false
  nullable = false
}

variable "enable_access_logs" {
  description = "Whether or not to enable access logs on the load balancer."
  type    = bool
  default = false
  nullable = false
}

variable "access_logs_bucket_name" {
  description = "The name of the S3 bucket in which to store access logs when `enable_access_logs` is `true`."
  type    = string
  default = null
}

variable "access_logs_bucket_prefix" {
  description = "The prefix to use for objects in the access logs S3 bucket when `enable_access_logs` is `true`. Logs are stored in the root if `null`."
  type    = string
  default = null
}
