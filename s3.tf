provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "s3-test" {
  bucket = "2018-10-30-kawsar-tf-test-bucket"
  acl    = "private"
  region   = "us-east-1"

  tags {
    Name        = "My bucket"
    Environment = "Dev"
    Owner       = "kawsar@hashicorp.com"
    TTL         = "48h"
  }
}