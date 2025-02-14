# Define variables for EC2 instance creation
variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "The name to tag the EC2 instance with"
  type        = string
}
variable "service_name" {
  description = "The name of the service for tagging the EC2 instance, which helps identify the service associated with this instance."
  type        = string
}

variable "app_team" {
  description = "The name of the application team responsible for the EC2 instance, used for tracking ownership and accountability."
  type        = string
}

variable "createdby" {
  description = "The name of the individual or system that created the EC2 instance, useful for audit trails and support."
  type        = string
}


variable "subnet_id" {
  description = "The subnet ID to launch the instance into"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}
