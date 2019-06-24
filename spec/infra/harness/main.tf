data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "network_load_balancer" {
  source = "../../../../"

  region                   = "${var.region}"
  vpc_id                   = "${data.terraform_remote_state.prerequisites.vpc_id}"
  subnet_ids               = "${split(",", data.terraform_remote_state.prerequisites.subnet_ids)}"
  listener_certificate_arn = "${data.terraform_remote_state.prerequisites.certificate_arn}"

  domain_name     = "${var.domain_name}"
  public_zone_id  = "${var.public_zone_id}"
  private_zone_id = "${var.private_zone_id}"

  component                        = "${var.component}"
  deployment_identifier            = "${var.deployment_identifier}"
  enable_cross_zone_load_balancing = "${var.enable_cross_zone_load_balancing}"

  idle_timeout = "${var.idle_timeout}"

  include_public_dns_record  = "${var.include_public_dns_record}"
  include_private_dns_record = "${var.include_private_dns_record}"

  expose_to_public_internet = "${var.expose_to_public_internet}"

  use_https             = "${var.use_https}"
  target_group_port     = "${var.target_group_port}"
  target_group_type     = "${var.target_group_type}"
  target_group_protocol = "${var.target_group_protocol}"

  health_check_port                = "${var.health_check_port}"
  health_check_protocol            = "${var.health_check_protocol}"
  health_check_interval            = "${var.health_check_interval}"
  health_check_unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
  health_check_healthy_threshold   = "${var.health_check_healthy_threshold}"
}
