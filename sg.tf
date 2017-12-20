resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.default.id}"

  # adopt default security group and drop all ingress/egress rules as per AWS
  # security best practices
}

resource "aws_security_group" "standard" {
  vpc_id = "${aws_vpc.default.id}"

  name        = "standard"
  description = "Standard network policy"
}

resource "aws_security_group_rule" "standard_ingress_ssh" {
  security_group_id = "${aws_security_group.standard.id}"

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = "${var.internal_networks}"
}

resource "aws_security_group_rule" "standard_ingress_http" {
  security_group_id = "${aws_security_group.standard.id}"

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = "${var.internal_networks}"
}

resource "aws_security_group_rule" "standard_ingress_https" {
  security_group_id = "${aws_security_group.standard.id}"

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = "${var.internal_networks}"
}

resource "aws_security_group_rule" "standard_ingress_rdp" {
  security_group_id = "${aws_security_group.standard.id}"

  type        = "ingress"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = "${var.internal_networks}"
}

# TODO this policy ensures that hosts cannot egress to internet even through
# the corporate network, do we really need that level of security?
resource "aws_security_group_rule" "standard_egress_ssh" {
  security_group_id = "${aws_security_group.standard.id}"

  type        = "egress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = "${var.internal_networks}"
}

resource "aws_security_group_rule" "standard_egress_http" {
  security_group_id = "${aws_security_group.standard.id}"

  type        = "egress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = "${var.internal_networks}"
}

resource "aws_security_group_rule" "standard_egress_https" {
  security_group_id = "${aws_security_group.standard.id}"

  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = "${var.internal_networks}"
}
