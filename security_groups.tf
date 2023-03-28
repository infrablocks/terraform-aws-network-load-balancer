resource "aws_security_group" "default" {
  for_each = (local.security_groups.default.associate) ? local.security_groups : {}

  name = "${var.component}-${var.deployment_identifier}"
  description = "NLB security group for: ${var.component}, deployment: ${var.deployment_identifier}"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.component}-${var.deployment_identifier}"
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
  }
}

resource "aws_security_group_rule" "default_ingress" {
  for_each = (local.security_groups.default.associate && local.security_groups.default.ingress_rule.include) ? local.listeners : {}

  type = "ingress"

  security_group_id = aws_security_group.default["default"].id

  protocol = "tcp"
  from_port = each.value.port
  to_port = each.value.port

  cidr_blocks = local.security_groups.default.ingress_rule.cidrs
}

resource "aws_security_group_rule" "default_egress" {
  for_each = (local.security_groups.default.associate && local.security_groups.default.egress_rule.include) ? local.security_groups : {}

  type = "egress"

  security_group_id = aws_security_group.default["default"].id

  protocol = "tcp"
  from_port = each.value.egress_rule.from_port
  to_port = each.value.egress_rule.to_port

  cidr_blocks = local.security_groups.default.egress_rule.cidrs
}
