# terraform-aws-s3-tests
Terraform code to create AWS S3 bucket with various configuration. This branch uses AWS Assume role authentication for the [Terraform AWS Provider](https://www.terraform.io/docs/providers/aws/#assume-role)

This repository uses Terraform to create an AWS S3 bucket with various methods:
1. Terraform OpenSource CLI - master branch.
2. [TFE CLI](https://github.com/hashicorp/tfe-cli) - depreciated. This will be replaced with the Terraform Helper tool.
3. CLI Driven Run - Please use the [enhanced_remote_backend branch](https://github.com/kawsark/terraform-aws-s3-tests/tree/enhanced_remote_backend)
4. Terraform OpenSource/TFE with AWS AssumeRole. Please use the [assumerole branch](https://github.com/kawsark/terraform-aws-s3-tests/tree/assumerole)
5. API Driven Run - [Terraform Enterprise API invocations using `curl`](curl.md)

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

## Steps using Terraform Cloud:
```
git clone https://github.com/kawsark/terraform-aws-s3-tests.git
cd terraform-aws-s3-tests
export TFE_TOKEN=<your_tfe_token>
export TFE_ORG=<your_tfe_org>
export TFE_WORKSPACE="terraform-aws-s3-tests"

tfe workspace list
tfe workspace new
tfe pushvars -senv-var "AWS_ACCESS_KEY_ID=aws_access_key_id"
tfe pushvars -senv-var "AWS_SECRET_ACCESS_KEY=aws_secret_access_key"
tfe pushvars -senv-var "CONFIRM_DESTROY=1"
tfe pushvars -var "bucket_name=tf-test-bucket-$(date +%s)"
tfe pushvars -var "role_arn=assume_role_arn"
tfe pushvars -env-var "CONFIRM_DESTROY=1"
tfe pushconfig -vcs false -poll 5 .

# View [TFE UI](https://app.terraform.io)
# Destroy bucket from UI
```
git clone https://github.com/kawsark/terraform-aws-s3-tests.git
cd terraform-aws-s3-tests
git checkout assumerole

## Steps using `aws sts assume-role` and Terraform Enterprise with [TFE CLI](https://github.com/hashicorp/tfe-cli)
```
git clone https://github.com/kawsark/terraform-aws-s3-tests.git
cd terraform-aws-s3-tests
export TFE_TOKEN=<your_tfe_token>
export TFE_ORG=<your_tfe_org>
export TFE_WORKSPACE="terraform-aws-s3-tests"

# Assume role via CLI:
# https://aws.amazon.com/premiumsupport/knowledge-center/iam-assume-role-cli/
# Use following command to look up the ARN for an existing role:
aws iam list-roles --query "Roles[?RoleName == 'test-role'].[RoleName, Arn]"

# Assume role:
export role_arn="<your_assume_role_arn>"
aws sts assume-role --role-arn "${role_arn}" --role-session-name AWSCLI-Session > assume_role.txt

export AWS_ACCESS_KEY_ID=$(cat assume_role.txt | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(cat assume_role.txt | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(cat assume_role.txt | jq -r .Credentials.SessionToken)

tfe workspace list
tfe workspace new
tfe pushvars -senv-var "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
tfe pushvars -senv-var "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
tfe pushvars -senv-var "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}"

tfe pushvars -senv-var "CONFIRM_DESTROY=1"
tfe pushvars -var "bucket_name=tf-test-bucket-$(date +%s)"
tfe pushconfig -vcs false -poll 5 .

# View [TFE UI](https://app.terraform.io)
# Destroy bucket from UI
```
