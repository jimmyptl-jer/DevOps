data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "example" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = "server"
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true

  tags = {
    Name        = var.instance_name
    "Service"   = var.service_name
    "AppTeam"   = var.app_team
    "CreatedBy" = var.createdby
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("server.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce",
      "sudo systemctl start docker",

      # Login to Docker Hub
      "sudo docker login -u '${var.docker_username}' -p '${var.docker_password}'",

      # Pull Docker images
      "sudo docker pull ${var.docker_username}/bookstore:client",
      "sudo docker pull ${var.docker_username}/bookstore:api",

      # Stop and remove any existing containers
      "sudo docker stop bookstore-client || true",
      "sudo docker rm bookstore-client || true",
      "sudo docker stop bookstore-api || true",
      "sudo docker rm bookstore-api || true",

      # Run the new containers
      "sudo docker run -d -p 80:80 --name bookstore-client ${var.docker_username}/bookstore:client",
      "sudo docker run -d -p 3000:3000 --name bookstore-api ${var.docker_username}/bookstore:api"
    ]
  }
}
