terraform {
  # Configure the backend for storing Terraform state files remotely
  backend "remote" {
    # The hostname of the Terraform Cloud instance
    hostname = "app.terraform.io"

    # The organization in Terraform Cloud where the workspace is located
    organization = "graywolf-tech-hub"

    workspaces {
      # The name of the workspace within the organization
      name = "aws-infra"
    }
  }
}
