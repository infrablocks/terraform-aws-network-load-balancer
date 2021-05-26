module "base_network" {
  source = "infrablocks/base-networking/aws"
  version = "3.0.0"

  region = var.region
  vpc_cidr = var.vpc_cidr
  availability_zones = var.availability_zones

  component = "${var.component}-net"
  deployment_identifier = var.deployment_identifier

  private_zone_id = var.private_zone_id
}

locals {
  address = "${var.component}-${var.deployment_identifier}.${var.domain_name}"
}

resource "aws_acm_certificate" "certificate" {
  domain_name = local.address
  validation_method = "DNS"

  tags = {
    Name = "cert-${var.component}-${var.deployment_identifier}"
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = aws_acm_certificate.certificate.domain_validation_options

  name = each.value.resource_record_name
  type = each.value.resource_record_type
  zone_id = var.public_zone_id
  records = [
    each.value.resource_record_value
  ]
  ttl = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}
