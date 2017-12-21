output "channel_id" {
  value = "${aws_config_delivery_channel.awsconfig.id}"
}

output "recorder_id" {
  value = "${aws_config_configuration_recorder.awsconfig.id}"
}
