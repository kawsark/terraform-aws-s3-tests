## Terraform Enterprise API invocations using `curl`
Steps:
```
git clone https://github.com/kawsark/terraform-aws-s3-tests.git
cd terraform-aws-s3-tests

# Set Environment variables:
export TFE_TOKEN=<your_tfetoken>
export TFE_ORG=<your_tfe_org>
export TFE_WORKSPACE="terraform-aws-s3-tests"
export TFE_ADDR="app.terraform.io"

# Set name of workspace in workspace.json:
sed "s/placeholder/${TFE_WORKSPACE}/" < api_templates/workspace.template.json > workspace.json

# Create workspace:
curl --header "Authorization: Bearer ${TFE_TOKEN}" --header "Content-Type: application/vnd.api+json" --request POST --data @workspace.json "https://${TFE_ADDR}/api/v2/organizations/${TFE_ORG}/workspaces" > workspace_result.txt

# Parse workspace_id from workspace_result:
export workspace_id=$(cat workspace_result.txt | jq -r .data.id)
echo "Workspace ID: " ${workspace_id}

# Build myconfig.tar.gz
tar -cvf myconfig.tar *.tf
gzip myconfig.tar

# Obtain Configuration version and upload URL
curl --header "Authorization: Bearer ${TFE_TOKEN}" --header "Content-Type: application/vnd.api+json" --data @api_templates/configversion.json "https://${TFE_ADDR}/api/v2/workspaces/${workspace_id}/configuration-versions" > configuration_version.txt

export config_version_id=$(cat configuration_version.txt | jq -r .data.id)
export upload_url=$(cat configuration_version.txt | jq -r '.["data"]["attributes"]["upload-url"]')
echo "Config Version ID: " ${config_version_id}
echo "Upload URL: " ${upload_url}

# Upload configuration
curl --request PUT -F 'data=@myconfig.tar.gz' "${upload_url}"

# Set bucket_name variable:
export key="bucket_name"
export value="tf-test-bucket-$(date +%s)"
export category="terraform"
export sensitive="false"

sed -e "s/my-organization/${TFE_ORG}/" -e "s/my-workspace/${TFE_WORKSPACE}/" -e "s/my-key/${key}/" -e "s/my-value/${value}/" -e "s/my-category/${category}/" -e "s/my-sensitive/${sensitive}/" < api_templates/variable.template.json  > variable.json

curl --header "Authorization: Bearer ${TFE_TOKEN}" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${TFE_ADDR}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${TFE_ORG}&filter%5Bworkspace%5D%5Bname%5D=${TFE_WORKSPACE}"

# Set AWS credentials:
export category="env"
export sensitive="true"

export key="AWS_ACCESS_KEY_ID"
export value="${AWS_ACCESS_KEY_ID}"

sed -e "s/my-organization/${TFE_ORG}/" -e "s/my-workspace/${TFE_WORKSPACE}/" -e "s/my-key/${key}/" -e "s/my-value/${value}/" -e "s/my-category/${category}/" -e "s/my-sensitive/${sensitive}/" < api_templates/variable.template.json  > variable.json

curl --header "Authorization: Bearer ${TFE_TOKEN}" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${TFE_ADDR}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${TFE_ORG}&filter%5Bworkspace%5D%5Bname%5D=${TFE_WORKSPACE}"

export key="AWS_SECRET_ACCESS_KEY"
export value="${AWS_SECRET_ACCESS_KEY}"

sed -e "s/my-organization/${TFE_ORG}/" -e "s/my-workspace/${TFE_WORKSPACE}/" -e "s/my-key/${key}/" -e "s/my-value/${value}/" -e "s/my-category/${category}/" -e "s/my-sensitive/${sensitive}/" < api_templates/variable.template.json  > variable.json

curl --header "Authorization: Bearer ${TFE_TOKEN}" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${TFE_ADDR}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${TFE_ORG}&filter%5Bworkspace%5D%5Bname%5D=${TFE_WORKSPACE}"

# Do a run
sed "s/workspace_id/$workspace_id/" < api_templates/run.template.json  > run.json
run_result=$(curl --header "Authorization: Bearer ${TFE_TOKEN}" --header "Content-Type: application/vnd.api+json" --data @run.json https://${TFE_ADDR}/api/v2/runs)

# Find Run id:
run_id=$(echo $run_result | jq -r .data.id)
echo "Run ID: " $run_id

# Check result:
check_result=$(curl --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${TFE_ADDR}/api/v2/runs/${run_id})

# Parse out the run status
run_status=$(echo $check_result | jq -r .data.attributes.status)

# List Runs:
# https://www.terraform.io/docs/enterprise/api/run.html#list-runs-in-a-workspace
curl \
  --header "Authorization: Bearer ${TFE_TOKEN}" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/workspaces/${workspace_id}/runs

# List State versions:
# https://www.terraform.io/docs/enterprise/api/state-versions.html#list-state-versions-for-a-workspace
curl \
  --header "Authorization: Bearer ${TFE_TOKEN}" \
  --header "Content-Type: application/vnd.api+json" \
  "https://${TFE_ADDR}/api/v2/state-versions?filter%5Bworkspace%5D%5Bname%5D=${TFE_WORKSPACE}&filter%5Borganization%5D%5Bname%5D=${TFE_ORG}"
```
