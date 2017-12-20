variable "bucket_name" {
  description = "The name of the bucket to be used for AWS_Config"
}

variable "role_arn" {
  description = "The ARN of the AWS Config role"
}

variable "provider_region" {
  description = "AWS Provider that specifies which region to deploy to"
}

variable "default_region" {
  description = "Default region used by terraform"
}

variable "depends_on" {
  description = "List of resources that module is dependent on"
}
