module "network_load_balancer" {
  source = "../../"

  region     = var.region
  vpc_id     = module.base_network.vpc_id
  subnet_ids = module.base_network.public_subnet_ids

  component             = var.component
  deployment_identifier = var.deployment_identifier

  expose_to_public_internet = true

  listeners = [
    {
      key : "default"
      port : 443
      protocol : "TLS"
      ssl_policy : "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
      certificate_arn : module.acm_certificate.certificate_arn
      default_action : {
        type : "forward"
        target_group_key : "default"
      }
    }
  ]
  target_groups = [
    {
      key : "default"
      port : 80
      protocol : "TCP"
      target_type : "instance",
      deregistration_delay : 60,
      health_check : {
        port : 80
        protocol : "HTTP"
        interval : 30
        healthy_threshold : 3
        unhealthy_threshold : 3
      }
    }
  ]

  dns = {
    domain_name : var.domain_name,
    records : [
      { zone_id : var.public_zone_id },
      { zone_id : var.private_zone_id }
    ]
  }
}
