provider "aws" {
  region = "us-east-1"
}

# Fetch the latest Ubuntu AMI dynamically
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

# Fetch the latest Amazon Linux 2 AMI dynamically
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch the default subnets (public subnets)
data "aws_subnet_ids" "default_public_subnets" {
  vpc_id = data.aws_vpc.default.id
}

# Security Group for allowing SSH and HTTP traffic
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow SSH, HTTPS and HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change for better security
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}

# Use an existing Key Pair (instead of generating one)
resource "aws_key_pair" "deployer" {
  key_name   = "web-server-key"
  public_key = file("server.pem")  # Ensure this is the corresponding public key
}


# Create the Ubuntu EC2 instance
resource "aws_instance" "web_ubuntu" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = "web-server-key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              systemctl enable apache2
              systemctl start apache2
              EOF

  tags = {
    Name = "ubuntu-web-server"
  }
}

# Create the Amazon Linux EC2 instance
resource "aws_instance" "web_linux" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = "web-server-key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "amazon-linux-web-server"
  }
}

# Variable for instance type
variable "instance_type" {
  description = "Instance type for EC2 instances"
  default     = "t3.micro"
}

# Output Public IPs
output "ubuntu_public_ip" {
  value = aws_instance.web_ubuntu.public_ip
}

output "amazon_linux_public_ip" {
  value = aws_instance.web_linux.public_ip
}



# Application Load Balancer
# Security Group for the Load Balancer
# Security Group for allowing SSH and HTTP traffic
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow SSH, HTTPS and HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change for better security
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Create the Target Group for the ALB
resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "web-target-group"
  }
}

# Register EC2 Instances with the Target Group
resource "aws_lb_target_group_attachment" "web_attachment_ubuntu" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = aws_instance.web_ubuntu.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_attachment_linux" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = aws_instance.web_linux.id
  port             = 80
}

# Create the ALB
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnet_ids.default_public_subnets.ids  # Use default subnets
  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "web-alb"
  }
}

# Create ALB Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
      message_body = "OK"
    }
  }
}

# Output ALB DNS Name
output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}
