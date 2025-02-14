terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "graywolf-tech-hub"
    workspaces {
      name = "aws-infra"
    }
  }
}
