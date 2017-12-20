provider "aws.awsconfig" {
  region = "${var.provider_region}"
}

resource "aws_config_configuration_recorder_status" "awsconfig" {
  provider   = "aws.awsconfig"
  name       = "${aws_config_configuration_recorder.awsconfig.name}"
  is_enabled = true
  depends_on = ["aws_config_delivery_channel.awsconfig"]
}

resource "aws_config_delivery_channel" "awsconfig" {
  provider       = "aws.awsconfig"
  s3_bucket_name = "${var.bucket_name}"
  depends_on     = ["aws_config_configuration_recorder.awsconfig"]
}

resource "aws_config_configuration_recorder" "awsconfig" {
  provider = "aws.awsconfig"
  role_arn = "${var.role_arn}"

  recording_group {
    all_supported                 = true
    include_global_resource_types = "${var.provider_region == var.default_region ? 1 : 0}"
  }

  depends_on = ["null_resource.dummy_dependency"]
}

# Note: This null_resource is required to ensure that the AWS Config Delivery Channel does not get created
# prior to the S3 bucket and Roles that this module is dependent on  TF Module invocation does not currently
# support native depends_on
resource "null_resource" "dummy_dependency" {
  triggers {
    dependency_id = "${var.depends_on}"
  }
}
