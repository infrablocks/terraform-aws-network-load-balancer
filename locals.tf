locals {
  dns = {
    domain_name : var.dns.domain_name,
    records : {for record in var.dns.records : record.zone_id => record}
  }
  target_groups = {for target_group in var.target_groups : target_group.key => target_group}
  listeners     = {for listener in var.listeners : listener.key => listener}

  raw_associate_default_security_group             = try(var.security_groups.default.associate, null)
  raw_include_default_security_group_ingress_rule  = try(var.security_groups.default.ingress_rule.include, null)
  raw_include_default_security_group_egress_rule   = try(var.security_groups.default.egress_rule.include, null)
  raw_default_security_group_ingress_rule_cidrs    = try(var.security_groups.default.ingress_rule.cidrs, null)
  raw_default_security_group_egress_rule_cidrs     = try(var.security_groups.default.egress_rule.cidrs, null)
  raw_default_security_group_egress_rule_from_port = try(var.security_groups.default.egress_rule.from_port, null)
  raw_default_security_group_egress_rule_to_port   = try(var.security_groups.default.egress_rule.to_port, null)

  associate_default_security_group            = local.raw_associate_default_security_group == null ? true : local.raw_associate_default_security_group
  include_default_security_group_ingress_rule = local.raw_include_default_security_group_ingress_rule == null ? true : local.raw_include_default_security_group_ingress_rule
  include_default_security_group_egress_rule  = local.raw_include_default_security_group_egress_rule == null ? true : local.raw_include_default_security_group_egress_rule
  default_security_group_ingress_rule_cidrs   = local.raw_default_security_group_ingress_rule_cidrs == null ? [
    data.aws_vpc.vpc.cidr_block
  ] : local.raw_default_security_group_ingress_rule_cidrs
  default_security_group_egress_rule_cidrs = local.raw_default_security_group_egress_rule_cidrs == null ? [
    data.aws_vpc.vpc.cidr_block
  ] : local.raw_default_security_group_egress_rule_cidrs
  default_security_group_egress_rule_from_port = local.raw_default_security_group_egress_rule_from_port == null ? 0 : local.raw_default_security_group_egress_rule_from_port
  default_security_group_egress_rule_to_port   = local.raw_default_security_group_egress_rule_to_port == null ? 65535 : local.raw_default_security_group_egress_rule_to_port

  security_groups = {
    default : {
      associate : local.associate_default_security_group
      ingress_rule : {
        include : local.include_default_security_group_ingress_rule,
        cidrs : local.default_security_group_ingress_rule_cidrs,
      },
      egress_rule : {
        include : local.include_default_security_group_egress_rule,
        from_port : local.default_security_group_egress_rule_from_port,
        to_port : local.default_security_group_egress_rule_to_port,
        cidrs : local.default_security_group_egress_rule_cidrs,
      }
    }
  }
}
