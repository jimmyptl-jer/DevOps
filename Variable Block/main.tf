# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}

# Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "demo_environment"
    Terraform   = "true"
  }
}

# Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnet_cidrs, each.value - 1) # Adjusting index for the list
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value - 1]

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

# Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnet_cidrs, each.value - 1) # Adjusting index for the list
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value - 1]
  map_public_ip_on_launch = true

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "demo_igw"
  }
}

# Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "demo_nat_gateway_eip"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name = "demo_nat_gateway"
  }
}

# Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name      = "demo_public_rtb"
    Terraform = "true"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name      = "demo_private_rtb"
    Terraform = "true"
  }
}

# Create route table associations
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public_subnets
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private_subnets
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = each.value.id
}

# Create a Variables Subnet
resource "aws_subnet" "variables_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.variables_sub_cidr
  availability_zone       = var.variables_sub_az
  map_public_ip_on_launch = var.variables_sub_auto_ip

  tags = {
    Name      = "variables_subnet"
    Terraform = "true"
  }
}
