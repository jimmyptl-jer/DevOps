# Output for VPC module
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# Output for public subnets
output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

# Output for private subnets (if needed)
output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# Output for security group
output "security_group_id" {
  description = "The ID of the security group used for the EC2 instance"
  value       = module.security_groups.security_group_id
}

# Output for EC2 instance
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2.instance_id
}
output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.ec2.instance_public_ip
}

output "instance_private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = module.ec2.instance_private_ip
}
