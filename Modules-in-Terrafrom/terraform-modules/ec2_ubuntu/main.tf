data "aws_ami" "latest_ubuntu" {
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
  ami           = data.aws_ami.latest_ubuntu.id # Use the dynamic AMI ID
  instance_type = var.instance_type             # Adjust the instance type as needed

  subnet_id = var.subnet_id

  tags = {
    Name = var.instance_name
  }
}

