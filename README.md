# terraform-aws-s3-tests
Terraform code to create AWS S3 bucket with various configuration. This branch uses an ehanced remote backend:
- Terraform Enterprise with [Enhanced Remote Backend](https://www.terraform.io/docs/backends/types/remote.html)
## Steps using Terraform Enterprise with [Enhanced Remote Backend](https://www.terraform.io/docs/backends/types/remote.html)

```
git clone https://github.com/kawsark/terraform-aws-s3-tests.git
cd terraform-aws-s3-tests
git checkout enhanced_remote_backend

# Copy the backend.tf.txample file and edit it
# Adjust your organization, workspace and TFE server address (if using Private TFE)
cp backend.tf.example backend.tf
vi backend.tf 

# Export credentials
export TFE_TOKEN=your-tfe-token
export AWS_ACCESS_KEY_ID=aws_access_key_id
export AWS_SECRET_ACCESS_KEY=aws_secret_access_key

# Create a tfvars file:
echo "bucket_name=\"tf-test-bucket-$(date +%s)\"" > terraform.auto.tfvars
echo "aws_access_key = \"${AWS_ACCESS_KEY_ID}\"" >> terraform.auto.tfvars
echo "aws_secret_key = \"${AWS_SECRET_ACCESS_KEY}\"" >> terraform.auto.tfvars

# Run terraform plan and apply:

terraform init
terraform plan 
terraform apply 

# Destroying the bucket:

terraform destroy
```
