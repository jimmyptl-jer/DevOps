terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  alias  = "US East (N. Virginia)"
  region = "us-east-1"
}

provider "aws" {
  alias  = "US East (Ohio)"
  region = "us-east-2"
}
