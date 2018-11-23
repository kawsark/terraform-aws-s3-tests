# terraform-aws-s3-tests
Terraform code to create AWS S3 bucket with various methods:
1. Terraform OpenSource CLI
2. Terraform Enterprise with [TFE CLI](https://github.com/hashicorp/tfe-cli)
3. Terraform Enterprise with [Enhanced Remote Backend](https://www.terraform.io/docs/backends/types/remote.html). Please use the [enhanced_remote_backend branch](https://github.com/kawsark/terraform-aws-s3-tests/tree/enhanced_remote_backend)
4. Terraform OpenSource and Enterprise with AWS AssumeRole. Please use the [assumerole branch](https://github.com/kawsark/terraform-aws-s3-tests/tree/assumerole)
5. [Terraform Enterprise API invocations using `curl`](curl.md)

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

## Steps using Terraform Enterprise with [TFE CLI](https://github.com/hashicorp/tfe-cli)
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
tfe pushconfig -vcs false -poll 5 .

# View [TFE UI](https://app.terraform.io)
# Destroy bucket from UI
```

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
