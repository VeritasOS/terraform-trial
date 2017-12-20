resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.default.id}"

  # adopt default security group and drop all ingress/egress rules as per AWS
  # security best practices
}
