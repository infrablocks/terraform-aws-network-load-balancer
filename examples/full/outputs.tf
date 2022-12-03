output "name" {
  value = module.network_load_balancer.name
}

output "vpc_id" {
  value = module.network_load_balancer.vpc_id
}

output "id" {
  value = module.network_load_balancer.id
}

output "arn" {
  value = module.network_load_balancer.arn
}

output "zone_id" {
  value = module.network_load_balancer.zone_id
}

output "dns_name" {
  value = module.network_load_balancer.name
}

output "address" {
  value = module.network_load_balancer.address
}

output "target_groups" {
  value = module.network_load_balancer.target_groups
}

output "listeners" {
  value = module.network_load_balancer.listeners
}

output "subnet_ids" {
  value = module.base_network.public_subnet_ids
}

output "vpc_cidr" {
  value = module.base_network.vpc_cidr
}

output "certificate_arn" {
  value = module.acm_certificate.certificate_arn
}