module "base_network" {
  source  = "infrablocks/base-networking/aws"
  version = "0.8.0-rc.1"

  region             = "${var.region}"
  vpc_cidr           = "${var.vpc_cidr}"
  availability_zones = "${var.availability_zones}"

  component             = "${var.component}-net"
  deployment_identifier = "${var.deployment_identifier}"
  dependencies          = "${var.dependencies}"

  private_zone_id = "${var.private_zone_id}"

  infrastructure_events_bucket = "${var.infrastructure_events_bucket}"
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = "${var.component}-${var.deployment_identifier}.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Name                 = "cert-${var.component}-${var.deployment_identifier}"
    Component            = "${var.component}"
    DeploymentIdentifier = "${var.deployment_identifier}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${var.public_zone_id}"
  records = ["${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
