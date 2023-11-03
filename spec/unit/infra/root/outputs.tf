output "vpc_id" {
  value = module.network_load_balancer.vpc_id
}

output "name" {
  value = module.network_load_balancer.name
}

output "id" {
  value = module.network_load_balancer.id
}

output "arn" {
  value = module.network_load_balancer.arn
}

output "arn_suffix" {
  value = module.network_load_balancer.arn_suffix
}

output "zone_id" {
  value = module.network_load_balancer.zone_id
}

output "dns_name" {
  value = module.network_load_balancer.dns_name
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
