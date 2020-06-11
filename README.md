# terraform-aws-s3-tests
Terraform code to create AWS S3 bucket with various configuration. 

This branch uses the CLI Driven Workflow using a [Remote Backend](https://www.terraform.io/docs/backends/types/remote.html)

## CLI Driven Run with [Remote Backend](https://www.terraform.io/docs/backends/types/remote.html)
Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY sensitive Environment variables on the TFE Workspace using the UI or using [Terraform Helper](https://github.com/hashicorp-community/tf-helper) tool. Steps for using the TF Helper tool is shown below.

```
git clone https://github.com/kawsark/terraform-aws-s3-tests.git
cd terraform-aws-s3-tests
git checkout enhanced_remote_backend

# Copy the backend.tf.txample file and edit it
# Adjust your organization, workspace and TFE server address (if using Private TFE)
cp backend.tf.example backend.tf
vi backend.tf
terraform workspace new cli 
#terraform workspace select cli
terraform init

# Setup API token for remote backend
tfh login

# Use the TF Helper tool steps to set variables:
export TFH_name="terraform-aws-s3-tests-cli"
export TFE_TOKEN="<API_token>"
export TFH_org="<<Organization_name>>"

tfh pushvars -senv-var AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
tfh pushvars -senv-var AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
tfh pushvars -env-var "CONFIRM_DESTROY=1"
tfh pushvars -var bucket_name="tf-test-bucket-$(date +%s)"

# Run terraform plan and apply:
terraform init
terraform plan 
terraform apply 

# Destroying the bucket:
terraform destroy
```
