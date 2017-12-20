variable "name" {
  description = "A name for this"
  type        = "string"
}

variable "vpc_cidr" {
  description = "Veritas assigned CIDR (ie: 10.10.0.0/24)"
  type        = "string"
}
