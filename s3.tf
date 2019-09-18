terraform {
  required_version = "<= 0.11.14"
}

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

variable "env" {
  default = "dev"
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "s3-test" {
  bucket = "${var.bucket_name}"
  acl    = "private"
  region   = "${var.aws_region}"

  tags {
    Name        = "${var.bucket_name}"
    Environment = "${var.env}"
    Owner       = "${var.owner}"
    TTL         = "${var.ttl}"
  }
}
