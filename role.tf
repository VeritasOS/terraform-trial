resource "aws_iam_role" "user" {
  name = "${var.name}-user"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:saml-provider/okta"
        },
        "Action": "sts:AssumeRoleWithSAML",
        "Condition": {
          "StringEquals": {
            "SAML:aud": "https://signin.aws.amazon.com/saml"
          }
        }
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "deny_igw" {
  name        = "${var.name}-deny-igw"
  path        = "/"
  description = "Deny Create/Attach Internet Gateway"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "DenyInternetGateway",
        "Effect": "Deny",
        "Action": [
          "ec2:AttachInternetGateway",
          "ec2:CreateInternetGateway"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_policy_attachment" "attach_user_deny_igw" {
  name  = "${var.name}-deny-igw-attach"
  roles = ["${aws_iam_role.user.id}"]

  policy_arn = "${aws_iam_policy.deny_igw.arn}"
}

resource "aws_iam_policy_attachment" "attach_user_power_user" {
  name  = "${var.name}-power-user-attach"
  roles = ["${aws_iam_role.user.id}"]

  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
