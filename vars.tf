variable "internal_networks" {
  description = "List of internal network cidrs"
  type        = "list"

  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

variable "name" {
  description = "A name for this"
  type        = "string"
}

variable "vpc_cidr" {
  description = "Veritas assigned CIDR (ie: 10.10.0.0/24)"
  type        = "string"
}
