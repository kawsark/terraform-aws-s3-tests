terraform {
  backend "remote" {
    hostname = "ptfe.therealk.com"
    organization = "kawsar-org"

    workspaces {
      name = "terraform-aws-s3"
    }
  }
}