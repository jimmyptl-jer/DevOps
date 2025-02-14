provider "aws" {
  region = "us-east-1"
}

# Call VPC module to create the VPC and subnets
module "vpc" {
  source               = "../terraform-modules/vpc"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_name             = "development-vpc"
}

# Call EC2 Linux module
module "ec2_linux" {
  source        = "../terraform-modules/ec2_linux"
  instance_type = "t2.micro"
  instance_name = "linux-ec2"

  # Pass the first public subnet from the VPC module
  subnet_id = element(module.vpc.public_subnet_ids, 0)
}

module "ec2_ubuntu" {
  source        = "../terraform-modules/ec2_ubuntu"
  instance_type = "t2.micro"
  instance_name = "ubuntu-ec2"

  # Pass the first public subnet from the VPC module
  subnet_id = element(module.vpc.public_subnet_ids, 0)
}


# Output the instance ID and VPC details
output "vpc_id" {
  value = module.vpc.vpc_id
}

# output "linux_ec2_instance_id" {
#   value = module.ec2_linux.id
# }

# output "linux_ec2_instance_id" {
#   value = module.ec2_linux.id
# }
