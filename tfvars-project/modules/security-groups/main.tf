# modules/security-groups/main.tf
resource "aws_security_group" "web_sg" {
  name        = var.sg_name
  vpc_id      = var.vpc_id
  description = "Security group for web instance"

  ingress {
    from_port   = var.ingress_port
    to_port     = var.ingress_port
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
