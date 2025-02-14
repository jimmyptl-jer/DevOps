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

variable "subnet_id" {
  description = "The subnet ID to launch the instance into"
  type        = string
}

