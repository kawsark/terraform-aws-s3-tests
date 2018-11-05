variable "owner" {
  default = "demouser"
}

variable "ttl" {
  default = "48h"
}

variable "bucket_name" {
  default = "tf-test-bucket"
}

variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "s3-test" {
  bucket = "${var.bucket_name}"
  acl    = "private"
  region   = "${var.aws_region}"

  tags {
    Name        = "My bucket"
    Environment = "Dev"
    Owner       = "kawsar@hashicorp.com"
    TTL         = "48h"
  }
}