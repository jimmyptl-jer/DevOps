# main.tf
locals {
  vpc_name      = "vpc-${var.environment}"
  instance_name = "WebServer-${var.environment}"
}

locals {
  service_name = "Automation"
  app_team     = "Cloud Team"
  createdby    = "terraform"
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  vpc_name             = local.vpc_name
}

module "security_groups" {
  source       = "./modules/security-groups"
  vpc_id       = module.vpc.vpc_id
  sg_name      = var.sg_name
  ingress_port = var.ingress_port
  cidr_block   = var.cidr_block
}

module "ec2" {
  source            = "./modules/ec2_linux"
  instance_type     = var.instance_type
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_groups.security_group_id
  instance_name     = local.instance_name
  service_name      = local.service_name
  app_team          = local.app_team
  createdby         = local.createdby

}
