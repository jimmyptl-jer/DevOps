resource "aws_vpc" "modules_vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.vpc_name
  }
}
