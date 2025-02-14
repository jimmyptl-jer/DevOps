# modules/security-groups/variables.tf
variable "sg_name" {
  description = "Security group name"
  type        = string
}

variable "ingress_port" {
  description = "The port to allow incoming traffic (e.g., 80 for HTTP)."
  type        = list(number)
}

variable "cidr_block" {
  description = "CIDR block for ingress"
  type        = string
}

variable "vpc_id" {
  description = "Security group belong to which VPC"
}
