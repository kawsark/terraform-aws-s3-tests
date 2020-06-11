# CLI Driven Run with AWS AssumeRole

This repository uses Terraform to create an AWS S3 bucket with various methods
1. Terraform OpenSource CLI - [master branch](https://github.com/kawsark/terraform-aws-s3-tests)
2. CLI Driven Run - Please use the [enhanced_remote_backend branch](https://github.com/kawsark/terraform-aws-s3-tests/tree/enhanced_remote_backend)
3. **CLI Driven Run with AWS AssumeRole** (this branch)
4. API Driven Run - [Terraform Enterprise API invocations using `curl`](https://github.com/kawsark/terraform-aws-s3-tests/blob/master/curl.md)

This branch uses AWS Assume role authentication for the [Terraform AWS Provider](https://www.terraform.io/docs/providers/aws/#assume-role)

Note: Using the assume_role option in the AWS provider does require bootstrapping with other AWS credentials or using the Instance profile. 
- If you generally use Terraform OSS in AWS, you may use the EC2 instance profile. 
- If you end up using Private Terraform Enterprise (TFE) in AWS, you can also use the EC2 instance profile.
- Witn the SaaS implementation of TFE you would need to provide AWS keys with suitable IAM policy to the AWS provider so that it could then assume some other role.

**Note:** to confirm that Terraform is performing an AssumeRole, you can set an environment variable `TF_LOG=1`. The plan output will then produce some debug output such as below:
```
2019-02-04T15:13:51.704Z [DEBUG] plugin.terraform-provider-aws_v1.57.0_x4: 2019/02/04 15:13:51 [INFO] Attempting to AssumeRole arn:aws:iam::753646501470:role/kawsar_assume_role_s3 (SessionName: "terraform-assume-role", ExternalId: "", Policy: "")
```

## Pre-requisites:
You will need an AWS Role ARN that will be the target of Assume Role. You can find the ARN from the Console or search via AWS CLI, then attempt an assume role via `aws sts assume-role` command:
```
export role_name=<name_of_existing_role>
aws iam list-roles --query "Roles[?RoleName == '${role_name}'].[RoleName, Arn]"
aws sts assume-role --role-arn "<role_arn>" --role-session-name AWSCLI-Session
```

## Steps using Terraform Cloud CLI Driven Run
Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY sensitive Environment variables on the TFE Workspace using the UI or using [Terraform Helper](https://github.com/hashicorp-community/tf-helper) tool. Steps for using the TF Helper tool is shown below.
```
git clone https://github.com/kawsark/terraform-aws-s3-tests.git
cd terraform-aws-s3-tests
git checkout assumerole

# Setup API token for remote backend
terraform login

# Copy the backend.tf.txample file and edit it
# Adjust your organization, workspace and TFE server address (if using Private TFE)
cp backend.tf.example backend.tf
vi backend.tf
terraform workspace new cli 
#terraform workspace select cli
terraform init

# Use the TF Helper tool steps to set variables:
export TFH_name="terraform-aws-s3-tests-cli"
export TFE_TOKEN="<API_token>"
export TFH_org="<<Organization_name>>"

tfh pushvars -senv-var AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
tfh pushvars -senv-var AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
tfh pushvars -var role_arn="$role_arn"
tfh pushvars -env-var "CONFIRM_DESTROY=1"
tfh pushvars -var bucket_name="tf-test-bucket-$(date +%s)"

# Run terraform plan and apply:
terraform init
terraform plan 
terraform apply 

# Destroying the bucket:
terraform destroy
```
