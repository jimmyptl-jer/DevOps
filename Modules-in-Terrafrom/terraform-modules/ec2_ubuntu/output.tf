output "ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}
