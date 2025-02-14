# Data source to get the current AWS region
data "aws_region" "current" {}

# Provider block to set the AWS region
provider "aws" {
  region = "us-east-1"
}

# Data source to fetch the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  # Filter to find Ubuntu AMIs
  owners = ["099720109477"] # Canonical (Ubuntu) account ID
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-*-amd64-server-*"] # Adjust according to the desired Ubuntu version
  }
}

# Data source to fetch the latest Amazon Linux AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  owners = ["137112412989"] # Amazon's owner ID for the official AMIs
}

# Data source to get available zones in the current region
data "aws_availability_zones" "available" {}

locals {
  # Define the EC2 instance type
  instance_type = "t2.micro"

  # Define the application name
  application = "api_server"

  # Define common tags for the instance
  tags = {
    team        = "api_mgmt_dev"                                         # Specify the team responsible for the instance
    application = "corp_api"                                             # Specify the application name for tagging
    server_name = "${local.application} ${data.aws_region.current.name}" # Construct the server name using variables
  }
}

# Resource to create multiple Ubuntu instances with dynamic naming
resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id # Use the specified AMI ID
  instance_type = local.instance_type    # Use the specified instance type

  # Apply the defined tags to the instance
  tags = merge(local.tags, {
    Name = "${local.application}-ubuntu-instance" # Unique Name for Ubuntu instance
  })

  # Specify the availability zone for the instance dynamically
  availability_zone = data.aws_availability_zones.available.names[0] # Use modulo for balancing across zones
}

# Resource to create multiple Amazon Linux instances with dynamic naming
resource "aws_instance" "linux" {
  ami           = data.aws_ami.latest_amazon_linux.id # Use the specified AMI ID
  instance_type = local.instance_type                 # Use the specified instance type

  # Apply the defined tags to the instance
  tags = merge(local.tags, {
    Name = "${local.application}-linux-instance" # Unique Name for Amazon Linux instance
  })

  # Specify the availability zone for the instance dynamically
  availability_zone = data.aws_availability_zones.available.names[0] # Use modulo for balancing across zones
}
