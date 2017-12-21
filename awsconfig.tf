resource "aws_s3_bucket" "aws_config" {
  bucket = "${var.name}-awsconfig"
  acl    = "log-delivery-write"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "Old Version Cleanup"
    prefix  = ""
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }

  lifecycle_rule {
    id      = "Log cleanup"
    prefix  = "logs/"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 150
    }
  }

  lifecycle_rule {
    id      = "aws config cleanup"
    prefix  = "AWSLogs/"
    enabled = true

    expiration {
      days = 185
    }
  }

  logging {
    target_bucket = "${var.name}-awsconfig"
    target_prefix = "logs/"
  }

  tags {
    Name = "${var.name}-awsconfig"
  }
}

resource "aws_iam_role" "aws_config" {
  name = "${var.name}-awsconfig"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "config.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "awsconfig_s3" {
  name        = "${var.name}-AWSConfig-S3"
  path        = "/"
  description = "Allow AWS Config access to store snapshots in S3."

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject*"
            ],
            "Resource": [
                "${aws_s3_bucket.aws_config.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
            ],
            "Condition": {
                "StringLike": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketAcl"
            ],
            "Resource": "${aws_s3_bucket.aws_config.arn}"
        }
    ]
  }
  EOF

  depends_on = ["aws_s3_bucket.aws_config"]
}

resource "aws_iam_role_policy_attachment" "aws_config_attach" {
  role       = "${aws_iam_role.aws_config.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"

  depends_on = ["aws_iam_policy.awsconfig_s3"]
}

resource "aws_iam_role_policy_attachment" "awsconfig_s3_attach" {
  role       = "${aws_iam_role.aws_config.name}"
  policy_arn = "${aws_iam_policy.awsconfig_s3.arn}"

  depends_on = ["aws_iam_policy.awsconfig_s3"]
}

module "awsconfig_uswest1" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "us-west-1"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_uswest2" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "us-west-2"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_useast1" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "us-east-1"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_useast2" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "us-east-2"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_cacentral1" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "ca-central-1"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_apsouth1" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "ap-south-1"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_apne1" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "ap-northeast-1"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_apne2" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "ap-northeast-2"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_apse1" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "ap-southeast-1"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_apse2" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "ap-southeast-2"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_eucentral1" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "eu-central-1"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_euwest1" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "eu-west-1"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_euwest2" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "eu-west-2"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}

module "awsconfig_saeast1" {
  source          = "mod/awsconfig"
  bucket_name     = "${aws_s3_bucket.aws_config.bucket}"
  role_arn        = "${aws_iam_role.aws_config.arn}"
  provider_region = "sa-east-1"
  default_region  = "${var.aws_region}"

  depends_on = "${aws_iam_role_policy_attachment.awsconfig_s3_attach.id}"
}
