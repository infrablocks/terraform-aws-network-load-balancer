output "name" {
  value = "${module.network_load_balancer.name}"
}

output "arn" {
  value = "${module.network_load_balancer.arn}"
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

output "target_group_name" {
  value = "${module.network_load_balancer.target_group_name}"
}

output "target_group_arn" {
  value = "${module.network_load_balancer.target_group_arn}"
}

output "vpc_id" {
  value = "${module.network_load_balancer.vpc_id}"
}

output "listener_arn" {
  value = "${module.network_load_balancer.listener_arn}"
}
