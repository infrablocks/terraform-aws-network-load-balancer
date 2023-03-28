locals {
  dns = {
    domain_name : var.dns.domain_name,
    records : {for record in var.dns.records : record.zone_id => record}
  }
  target_groups = {for target_group in var.target_groups : target_group.key => target_group}
  listeners = {for listener in var.listeners : listener.key => listener}
}
