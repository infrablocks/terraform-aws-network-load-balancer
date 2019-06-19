output "name" {
  value = "${module.network_load_balancer.name}"
}

output "zone_id" {
  value = "${module.network_load_balancer.zone_id}"
}

output "dns_name" {
  value = "${module.network_load_balancer.dns_name}"
}

output "address" {
  value = "${module.network_load_balancer.address}"
}
