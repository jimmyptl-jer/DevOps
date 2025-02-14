terraform {
  backend "s3" {
    bucket = "graywolf-terraform-bucket"
    key    = "dev/aws_infra"
    region = "us-east-1"

    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
