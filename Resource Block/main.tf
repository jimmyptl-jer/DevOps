# Define the provider as AWS and specify the region
data "aws_region" "current" {}

provider "aws" {
  region = "us-east-1"
}


# Create a VPC with a /16 CIDR block, enabling DNS support and hostnames
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16" # Defines the IP range for the VPC
  enable_dns_support   = true          # Enable DNS resolution within the VPC
  enable_dns_hostnames = true          # Enable DNS hostnames within the VPC

  tags = {
    Name = "terraform_vpc-${data.aws_region.current.name}" # Tag the VPC for identification
  }
}

# Create an Internet Gateway that allows public subnets to access the internet
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id # Associate the Internet Gateway with the created VPC

  tags = {
    Name = "terraform_igw" # Tag for the Internet Gateway
  }
}

# Create Public Subnets in different availability zones with internet access
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id # Associate the subnet with the VPC
  cidr_block              = "10.0.1.0/24"     # Subnet CIDR block
  availability_zone       = "us-east-1a"      # Specify the AZ (us-east-1a)
  map_public_ip_on_launch = true              # Automatically assign a public IP to instances

  tags = {
    Name = "terrafom_PublicSubnet1" # Tag for the subnet
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "terrafom_PublicSubnet2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "terrafom_PublicSubnet3"
  }
}

# Create Private Subnets for backend resources without direct internet access
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id # Associate the subnet with the VPC
  cidr_block        = "10.0.4.0/24"     # Private subnet CIDR block
  availability_zone = "us-east-1a"      # Specify the AZ (us-east-1a)

  tags = {
    Name = "terrafom_PrivateSubnet1" # Tag for the private subnet
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "terrafom_PrivateSubnet2"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "terrafom_PrivateSubnet2"
  }
}

# Create an Elastic IP to associate with the NAT Gateway for private subnet internet access
resource "aws_eip" "nat_eip" {
  domain     = "vpc" # Enable the Elastic IP for VPC use
  depends_on = [aws_internet_gateway.my_igw]

  tags = {
    Name = "terrafom_NATGatewayEIP"
  }
}

# Create a NAT Gateway in one of the public subnets to allow private subnets to access the internet
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id            # Associate the Elastic IP with the NAT Gateway
  subnet_id     = aws_subnet.public_subnet_1.id # Place the NAT Gateway in the public subnet

  tags = {
    Name = "terrafom_NATGateway" # Tag for the NAT Gateway
  }
}

# Create a route table for public subnets to allow direct internet access via the Internet Gateway
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id # Associate the route table with the VPC

  route {
    cidr_block = "0.0.0.0/0"                    # Route all traffic
    gateway_id = aws_internet_gateway.my_igw.id # Use the Internet Gateway for this route
  }

  tags = {
    Name = "terrafom_PublicRouteTable" # Tag for the public route table
  }
}

# Associate Public Subnets with the Public Route Table for internet access
resource "aws_route_table_association" "public_subnet_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id # Associate the first public subnet with the route table
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_assoc_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a route table for private subnets to route traffic through the NAT Gateway
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id # Associate the route table with the VPC

  route {
    cidr_block     = "0.0.0.0/0"                       # Route all traffic
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id # Use the NAT Gateway for internet access
  }

  tags = {
    Name = "terrafom_PrivateRouteTable" # Tag for the private route table
  }
}

# Associate Private Subnets with the Private Route Table for internet access via NAT Gateway
resource "aws_route_table_association" "private_subnet_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id # Associate the first private subnet with the route table
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_security_group" "my-new-security-group" {
  name        = "web_server_inbound"
  description = "Allow inbound traffic on tcp/443"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "Allow 443 from the Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "web_server_inbound"
    Purpose = "Intro to Resource Blocks Lab"
  }
}

resource "random_id" "randomness" {
  byte_length = 16
}

resource "aws_s3_bucket" "S3-bucket" {
  bucket = "graywolf-bucket-${random_id.randomness.hex}"

  tags = {
    Name    = "Graywolf Bucket"
    Purpose = "Intro to Resource Blocks Lab"
  }
}

resource "aws_s3_bucket_ownership_controls" "my_new_bucket_acl" {
  bucket = aws_s3_bucket.S3-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
