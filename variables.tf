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

variable "security_groups" {
  description = "Details of security groups to add to the NLB, including the default security group."
  type = object({
    default: object({
      associate: string,
      ingress_rule: object({
        include: string,
        cidrs: list(string)
      }),
      egress_rule: object({
        include: string,
        from_port: number,
        to_port: number,
        cidrs: list(string)
      }),
    })
  })
  default = {
    default: {
      associate: true
      ingress_rule: {
        include: true,
        cidrs: null
      },
      egress_rule: {
        include: true,
        from_port: 0,
        to_port: 65535,
        cidrs: null
      }
    }
  }
}
