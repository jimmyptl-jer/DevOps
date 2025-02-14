## Title: **Step-by-Step Guide to Provisioning an AWS Infrastructure with Terraform**

### Introduction

In this article, we’ll go through the process of setting up an AWS infrastructure from scratch using Terraform. This guide is ideal for beginners interested in Infrastructure as Code (IaC) concepts. By the end, you’ll know how to create a Virtual Private Cloud (VPC) with both public and private subnets, set up NAT and internet gateways for controlled internet access, and deploy an EC2 instance with a provisioned Nginx server, all automated with Terraform.

### Prerequisites

Before getting started, you’ll need the following:

1. **AWS Account**: Ensure access to an AWS account.
2. **Terraform Installed**: You can install it from [Terraform’s official installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli).
3. **AWS CLI Configured**: If not already done, configure your AWS CLI with `aws configure` to authenticate with AWS.
4. **Basic AWS and Terraform Knowledge**: Familiarity with concepts like VPC, subnets, security groups, and basic Terraform syntax will be helpful.

### Project Overview

This project covers the following infrastructure components:
1. **Creating a VPC** with DNS support for hostname resolution.
2. **Setting up Public and Private Subnets** across different availability zones for high availability.
3. **Configuring Internet and NAT Gateways** for internet access.
4. **Setting up Route Tables** for directing traffic in public and private subnets.
5. **Creating a Security Group** to control traffic to and from the EC2 instance.
6. **Deploying an EC2 Instance** with remote-exec provisioner to initialize an Nginx server.

---

### Step 1: Define the AWS Provider and Region Data

Terraform requires a provider configuration to know where to deploy resources. The `aws_region` data source fetches the default region for AWS.

```hcl
# Define AWS provider and fetch current region
data "aws_region" "current" {}
```

### Step 2: Set Up a VPC

A Virtual Private Cloud (VPC) acts as a secure network boundary within which we can create AWS resources. Here, we enable DNS support to assign DNS hostnames to instances.

```hcl
# VPC Configuration
resource "aws_vpc" "server_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "server-vpc-${data.aws_region.current.name}"
  }
}
```

**Explanation**:  
- `cidr_block`: Defines the IP range for our VPC.
- `enable_dns_hostnames` and `enable_dns_support`: Enable DNS settings for instances, allowing them to resolve domain names.

### Step 3: Create Public and Private Subnets

Subnets are subdivisions of the VPC. Public subnets allow instances to access the internet, while private subnets are isolated. We create two of each type for redundancy across availability zones.

```hcl
# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.server_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "server-vpc_public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.server_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "server-vpc_public-subnet-2"
  }
}
```

**Explanation**:
- `map_public_ip_on_launch`: Automatically assigns a public IP to instances launched in these subnets.

### Step 4: Set Up the Internet Gateway and NAT Gateway

An **Internet Gateway** allows resources in public subnets to communicate with the internet, while a **NAT Gateway** allows instances in private subnets to access the internet securely (e.g., for software updates).

```hcl
# Internet Gateway
resource "aws_internet_gateway" "server_vpc_igw" {
  vpc_id = aws_vpc.server_vpc.id

  tags = {
    Name = "server-vpc_igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "server_nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.server_vpc_igw]

  tags = {
    Name = "server_vpc_eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "server_vpc_nat_gw" {
  allocation_id = aws_eip.server_nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "server-vpc_nat_gw"
  }
}
```

### Step 5: Configure Route Tables

Each subnet needs a route table to manage traffic flow. We configure a public route table for internet-bound traffic and a private route table to direct traffic through the NAT Gateway.

```hcl
# Public Route Table
resource "aws_route_table" "server_vpc_public_route_table" {
  vpc_id = aws_vpc.server_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.server_vpc_igw.id
  }
}

# Private Route Table
resource "aws_route_table" "server_vpc_private_route_table" {
  vpc_id = aws_vpc.server_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.server_vpc_nat_gw.id
  }
}
```

### Step 6: Associate Route Tables with Subnets

Link each subnet to the appropriate route table so they follow the correct routing rules.

```hcl
# Route Table Association for Public and Private Subnets
resource "aws_route_table_association" "public_subnet_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.server_vpc_public_route_table.id
}

resource "aws_route_table_association" "private_subnet_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.server_vpc_private_route_table.id
}
```

### Step 7: Define Security Group for EC2 Instance

Security groups act as firewalls for instances. Here, we allow HTTP, HTTPS, and SSH access.

```hcl
resource "aws_security_group" "server-sg" {
  name        = "web"
  description = "Allow inbound traffic on port 443,22,80 - HHTP,HTTPS & SSH"
  vpc_id      = aws_vpc.server_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Step 8: Provision the EC2 Instance and Configure Remote Exec

Finally, create an EC2 instance in the public subnet and configure Nginx using `remote-exec`.

```hcl
resource "aws_instance" "server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "server"
  vpc_security_group_ids      = [aws_security_group.server-sg.id]
  subnet_id                   = aws_subnet.public_subnet_1.id

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("server.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }

  tags = {
    Name = "Server"
  }
}
```

### Conclusion

This guide walked you through creating a comprehensive AWS setup using Terraform, from VPC and subnet creation to deploying an EC2 instance with a provisioned Nginx server. Now, you’re ready to apply these concepts to more advanced scenarios!

**Next Steps**: Try modifying this setup by adding more subnets, exploring additional AWS services, or automating this process further with CI/CD pipelines.
