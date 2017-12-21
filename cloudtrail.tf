resource "aws_cloudwatch_log_group" "cloudtrail-global" {
  name = "${var.name}-global"

  tags {
    Name = "${var.name}-global"
  }
}

# This bucket is used for AWS Cloudtrail logs and has MFA delete enabled.
resource "aws_s3_bucket" "default_trail" {
  bucket = "${var.name}-trail"
  acl    = "log-delivery-write"

  versioning {
    enabled    = true
    mfa_delete = "${var.mfa_delete}"
  }

  logging {
    target_bucket = "${var.name}-trail"
    target_prefix = "logs/"
  }

  tags {
    Name = "${var.name}-trail"
  }
}

resource "aws_s3_bucket_policy" "default_trail" {
  bucket = "${aws_s3_bucket.default_trail.id}"

  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "AWSCloudTrailAclCheck",
              "Effect": "Allow",
              "Principal": {
                  "Service": "cloudtrail.amazonaws.com"
              },
              "Action": "s3:GetBucketAcl",
              "Resource": "arn:aws:s3:::${aws_s3_bucket.default_trail.id}"
          },
          {
              "Sid": "AWSCloudTrailWrite",
              "Effect": "Allow",
              "Principal": {
                  "Service": "cloudtrail.amazonaws.com"
              },
              "Action": "s3:PutObject",
              "Resource": "arn:aws:s3:::${aws_s3_bucket.default_trail.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
              "Condition": {
                  "StringEquals": {
                      "s3:x-amz-acl": "bucket-owner-full-control"
                  }
              }
          }
      ]
  }
  EOF
}

resource "aws_kms_key" "cloudtrail" {
  description         = "Cloudtrail logs"
  enable_key_rotation = true

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow CloudTrail to encrypt logs",
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "kms:GenerateDataKey*",
        "Resource": "*",
        "Condition": {
          "StringLike": {
            "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      },
      {
        "Sid": "Allow CloudTrail to describe key",
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "kms:DescribeKey",
        "Resource": "*"
      },
      {
        "Sid": "Allow principals in the account to decrypt log files",
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": [
          "kms:Decrypt",
          "kms:ReEncryptFrom"
        ],
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
          },
          "StringLike": {
            "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      },
      {
        "Sid": "Allow alias creation during setup",
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": "kms:CreateAlias",
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}",
            "kms:ViaService": "ec2.${var.aws_region}.amazonaws.com"
          }
        }
      },
      {
        "Sid": "Enable cross account log decryption",
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": [
          "kms:Decrypt",
          "kms:ReEncryptFrom"
        ],
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
          },
          "StringLike": {
            "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      }
    ]
  }
  EOF

  tags {
    Name = "cloudtrail"
  }
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${var.name}-cloudtrail"
  target_key_id = "${aws_kms_key.cloudtrail.key_id}"
}

resource "aws_iam_role" "cloudtrail-cloudwatchlogs" {
  name = "${var.name}-trail-watchlogs"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "cloudtrail-cloudwatchlogs-policy" {
  name = "${var.name}-trail-watchlogs"
  role = "${aws_iam_role.cloudtrail-cloudwatchlogs.id}"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": [
          "${replace(aws_cloudwatch_log_group.cloudtrail-global.arn, "*", "")}log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${var.aws_region}*"
        ]
      }
    ]
  }
  EOF
}

resource "aws_cloudtrail" "default" {
  name                       = "${var.name}-default"
  s3_bucket_name             = "${aws_s3_bucket.default_trail.id}"
  is_multi_region_trail      = true
  enable_log_file_validation = true
  kms_key_id                 = "${aws_kms_key.cloudtrail.arn}"
  cloud_watch_logs_role_arn  = "${aws_iam_role.cloudtrail-cloudwatchlogs.arn}"
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail-global.arn}"

  tags {
    Name = "${var.name}-default"
  }

  depends_on = [
    "aws_iam_role_policy.cloudtrail-cloudwatchlogs-policy",
    "aws_cloudwatch_log_group.cloudtrail-global",
    "aws_kms_alias.cloudtrail",
  ]
}
