
# Create the EC2 instance
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu) AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "example" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id # Use the subnet ID passed as a variable
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name        = var.instance_name
    "Service"   = var.service_name
    "AppTeam"   = var.app_team
    "CreatedBy" = var.createdby
  }
}

#
