# terraform-aws-s3-tests
This repository uses Terraform to create an AWS S3 bucket with various methods:
1. Terraform OpenSource CLI - master branch.
2. CLI Driven Run - Please use the [enhanced_remote_backend branch](https://github.com/kawsark/terraform-aws-s3-tests/tree/enhanced_remote_backend)
3. Terraform OpenSource/TFE with AWS AssumeRole. Please use the [assumerole branch](https://github.com/kawsark/terraform-aws-s3-tests/tree/assumerole)
4. API Driven Run - [Terraform Enterprise API invocations using `curl`](curl.md)

## Steps using Terraform OpenSource
```
git clone https://github.com/kawsark/terraform-aws-s3-tests.git
cd terraform-aws-s3-tests
export AWS_ACCESS_KEY_ID=access-key-id
export AWS_SECRET_ACCESS_KEY=secret-access-key

# Optionally export a bucket name appending UTC seconds:
export TF_VAR_bucket_name="tf-test-bucket-$(date +%s)"

# Create bucket:
terraform init
terraform plan
terraform apply

# Destroy the bucket afterwards:
terraform destroy
```