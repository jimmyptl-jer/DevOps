# terraform-modules/vpc/modules_vpc.tf

resource "aws_vpc" "modules_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.modules_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.modules_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Private Subnet ${count.index}"
  }
}

resource "aws_internet_gateway" "modules_vpc_igw" {
  vpc_id = aws_vpc.modules_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_eip" "nat_eip" {
  domain     = "vpc" # Enable the Elastic IP for VPC use
  depends_on = [aws_internet_gateway.modules_vpc_igw]

  tags = {
    Name = "terrafom_NATGatewayEIP"
  }
}

resource "aws_nat_gateway" "modules_vpc" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.vpc_name}-nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.modules_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.modules_vpc_igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-route"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.modules_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.modules_vpc.id
  }

  tags = {
    Name = "${var.vpc_name}-private-route"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
