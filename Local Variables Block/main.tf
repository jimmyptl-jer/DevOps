provider "aws" {
  region = local.region # Set the AWS region from local variables
}

# Data source to fetch the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true # Get the most recent AMI

  # Filter to find Ubuntu AMIs
  owners = ["099720109477"] # Canonical (Ubuntu) account ID
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-*-amd64-server-*"] # Adjust according to the desired Ubuntu version
  }
}

locals {
  # Define the AWS region for the resources
  region = "us-east-1"

  # Define the EC2 instance type
  instance_type = "t2.micro"

  # Get the current timestamp
  time = timestamp()

  # Define the application name
  application = "api_server"

  # Define common tags for the instance
  tags = {
    Name        = "${local.application}-instance"
    team        = "api_mgmt_dev"                         # Specify the team responsible for the instance
    application = "corp_api"                             # Specify the application name for tagging
    server_name = "${local.application} ${local.region}" # Construct the server name using variables
  }
}

resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.ubuntu.id # Use the specified AMI ID
  instance_type = local.instance_type    # Use the specified instance type
  tags          = local.tags             # Apply the defined tags to the instance

  # Specify the availability zone for the instance using the local region
  availability_zone = "${local.region}a" # Replace 'a' with the desired AZ suffix if necessary
}
