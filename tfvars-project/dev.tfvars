# dev.tfvars

aws_region           = "us-east-1"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
instance_type        = "t2.micro"
sg_name              = "dev-web-sg"
ingress_port         = 80
cidr_block           = "0.0.0.0/0"
