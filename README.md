# terraform-aws-s3-tests
Terraform code to create AWS S3 bucket with various configuration. This branch uses AWS Assume role authentication for the [Terraform AWS Provider](https://www.terraform.io/docs/providers/aws/#assume-role)

Note: Using the assume_role option in the AWS provider does require bootstrapping with other AWS credentials or using the Instance profile. 
- If you generally use Terraform OSS in AWS, you may use the EC2 instance profile. 
- If you end up using Private Terraform Enterprise (TFE) in AWS, you can also use the EC2 instance profile.
- Witn the SaaS implementation of TFE you would need to provide AWS keys with suitable IAM policy to the AWS provider so that it could then assume some other role.

## Pre-requisite:
You will need an AWS Role ARN that will be the target of Assume Role. You can find the ARN from the Console or search via AWS CLI:
```
aws iam list-roles --query "Roles[?RoleName == 'test-role'].[RoleName, Arn]"
```

## Steps using TFE SaaS:
```
git clone https://github.com/kawsark/terraform-aws-s3-tests.git
cd terraform-aws-s3-tests
export TFE_TOKEN=tfe_saas_token
export TFE_WORKSPACE="terraform-aws-s3-tests"

tfe workspace list
tfe workspace new
tfe pushvars -senv-var "AWS_ACCESS_KEY_ID=aws_access_key_id"
tfe pushvars -senv-var "AWS_SECRET_ACCESS_KEY=aws_secret_access_key"
tfe pushvars -env-var "CONFIRM_DESTROY=1"
tfe pushvars -var "bucket_name=tf-test-bucket-$(date +%s)"
tfe pushvars -var "role_arn=assume_role_arn"
tfe pushconfig -vcs false -poll 5 .

# View [TFE UI](https://app.terraform.io)
# Destroy bucket and workspace from UI
```

## Steps using Terraform OSS
```
git clone https://github.com/kawsark/terraform-aws-s3-tests.git
cd terraform-aws-s3-tests
git checkout assumerole

# Export AWS credentials (Not needed if running with appropriate EC2 instance profile)
export AWS_ACCESS_KEY_ID=aws_access_key_id
export AWS_SECRET_ACCESS_KEY=aws_secret_access_key

# Export Terraform variables:
export TF_VAR_bucket_name="tf-test-bucket-$(date +%s)"
export TF_VAR_role_arn="assume_role_arn"

# Run terraform plan and apply:

terraform init
terraform plan 
terraform apply 
```
