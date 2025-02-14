# Get the current AWS region
data "aws_region" "current" {}

######################
# VPC Configuration
######################

# Create a VPC with DNS hostnames and support enabled
resource "aws_vpc" "server_vpc" {
  cidr_block           = "10.0.0.0/16" # Define CIDR block for the VPC
  enable_dns_hostnames = true          # Enable DNS hostnames for instances
  enable_dns_support   = true          # Enable DNS support in VPC

  tags = {
    Name = "server-vpc-${data.aws_region.current.name}"
  }
}

######################
# Subnet Configuration
######################

# Create a public subnet in Availability Zone us-east-1a with automatic public IP assignment
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.server_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # Automatically assign public IP on launch

  tags = {
    Name = "server-vpc_public-subnet-1"
  }
}

# Create another public subnet in Availability Zone us-east-1b with automatic public IP assignment
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.server_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "server-vpc_public-subnet-2"
  }
}

# Create a private subnet in Availability Zone us-east-1a without public IP assignment
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.server_vpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "server-vpc_private-subnet-1"
  }
}

# Create another private subnet in Availability Zone us-east-1b without public IP assignment
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.server_vpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "server-vpc_private-subnet-2"
  }
}

######################
# Internet Gateway
######################

# Create an Internet Gateway for the VPC to enable internet access
resource "aws_internet_gateway" "server_vpc_igw" {
  vpc_id = aws_vpc.server_vpc.id

  tags = {
    Name = "server-vpc_igw"
  }
}

######################
# NAT Gateway and Elastic IP
######################

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "server_nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.server_vpc_igw] # Ensure Internet Gateway is created first

  tags = {
    Name = "server_vpc_eip"
  }
}

# Create a NAT Gateway in the public subnet to allow internet access for private subnets
resource "aws_nat_gateway" "server_vpc_nat_gw" {
  allocation_id = aws_eip.server_nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "server-vpc_nat_gw"
  }
}

######################
# Route Tables
######################

# Create a public route table with a default route to the Internet Gateway
resource "aws_route_table" "server_vpc_public_route_table" {
  vpc_id = aws_vpc.server_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # Default route to the Internet
    gateway_id = aws_internet_gateway.server_vpc_igw.id
  }
}

# Create a private route table with a default route to the NAT Gateway
resource "aws_route_table" "server_vpc_private_route_table" {
  vpc_id = aws_vpc.server_vpc.id

  route {
    cidr_block     = "0.0.0.0/0" # Default route through NAT for private subnets
    nat_gateway_id = aws_nat_gateway.server_vpc_nat_gw.id
  }
}

######################
# Route Table Associations
######################

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.server_vpc_public_route_table.id
}

resource "aws_route_table_association" "public_subnet_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.server_vpc_public_route_table.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.server_vpc_private_route_table.id
}

resource "aws_route_table_association" "private_subnet_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.server_vpc_private_route_table.id
}

######################
# Security Group
######################

# Security group allowing HTTP, HTTPS, and SSH access from anywhere
resource "aws_security_group" "server-sg" {
  name        = "web"
  description = "Allow inbound traffic on port 443, 22, 80 - HTTP, HTTPS & SSH"
  vpc_id      = aws_vpc.server_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Server-sg"
  }
}

######################
# EC2 Instance Configuration
######################

# Find the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Launch an EC2 instance in the public subnet with SSH access
resource "aws_instance" "server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "server" # Key for SSH access, replace with your actual key name
  vpc_security_group_ids      = [aws_security_group.server-sg.id]
  subnet_id                   = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true # Enable public IP for the instance

  tags = {
    Name = "Server"
  }

  # Connection details for remote-exec
  connection {
    type        = "ssh"
    user        = "ubuntu"           # Default user for Ubuntu AMIs
    private_key = file("server.pem") # Path to SSH private key
    host        = self.public_ip
  }

  # Provisioner to run commands on the EC2 instance
  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",         # Update package lists
      "sudo apt install -y nginx",  # Install Nginx
      "sudo systemctl start nginx", # Start Nginx
      "sudo systemctl enable nginx" # Enable Nginx to start on boot
    ]
  }
}
