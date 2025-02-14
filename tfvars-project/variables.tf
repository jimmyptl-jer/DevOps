variable "environment" {
  description = "The environment (dev, prod, test)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region where the resources will be deployed."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. This defines the IP range for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "instance_type" {
  description = "The type of EC2 instance (e.g., t2.micro, t3.large) that will be launched."
  default     = "t2.micro"
}

variable "sg_name" {
  description = "The name of the security group that will be created."
  default     = "web-sg"
}

variable "ingress_port" {
  description = "The port to allow incoming traffic (e.g., 80 for HTTP)."
  default     = 80
}

variable "cidr_block" {
  description = "The CIDR block from which traffic is allowed for ingress. Typically '0.0.0.0/0' allows all traffic."
  default     = "0.0.0.0/0"
}

