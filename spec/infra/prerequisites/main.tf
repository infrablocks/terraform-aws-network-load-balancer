locals {
  address = "${var.component}-${var.deployment_identifier}.${var.domain_name}"
}

module "base_network" {
  source = "infrablocks/base-networking/aws"
  version = "4.0.0"

  region = var.region
  vpc_cidr = var.vpc_cidr
  availability_zones = var.availability_zones

  component = "${var.component}-net"
  deployment_identifier = var.deployment_identifier

  private_zone_id = var.private_zone_id
}

module "acm_certificate" {
  source = "infrablocks/acm-certificate/aws"
  version = "1.0.0"

  domain_name = local.address
  domain_zone_id = var.public_zone_id
  subject_alternative_name_zone_id = var.public_zone_id

  providers = {
    aws.certificate = aws
    aws.domain_validation = aws
    aws.san_validation = aws
  }
}
