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

<<<<<<< HEAD
=======

>>>>>>> 0cba79d9c67c1b1b904a53bebeaa657e1a38074c
variable "aws_access_key" { }

variable "aws_secret_key" { }

provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
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