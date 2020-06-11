variable "aws_session_name" {
  description = "Optional session name to supply when performing AssumeRole call"
  default     = "terraform-assume-role"
}

variable "role_arn" {
  description = "The ARN of an existing role that Terraform should Assume"
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.role_arn
    session_name = var.aws_session_name
  }
}

