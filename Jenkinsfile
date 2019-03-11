pipeline {

agent any

    environment {
        GIT_REPO="https://github.com/kawsark/terraform-aws-s3-tests.git"
        GIT_ROOT="terraform-aws-s3-tests"
        WORKING_DIR="./"
        GIT_BRANCH="enhanced_remote_backend"
        TFE_NAME="app.terraform.io"
        TFE_ORG="kawsar-org"
        TFE_API_URL="${TFE_URL}/api/v2"
        TFE_WORKSPACE_PRE="aws-s3-jenkins"
        AWS_ACCESS_KEY_ID=credentials("AWS_ACCESS_KEY_ID")
        AWS_SECRET_ACCESS_KEY=credentials("AWS_SECRET_ACCESS_KEY")
        TFE_TOKEN=credentials("TFE_TOKEN")
    }
    
    stages {
     
     stage('Preparation') {
          steps {
            sh '''
            export PATH="/usr/local/bin:${PATH}"
            rm -rf ${GIT_ROOT} && git clone ${GIT_REPO}
            cd ${GIT_ROOT}/${WORKING_DIR} && git fetch && git checkout ${GIT_BRANCH}
            export TFE_WORKSPACE="${TFE_WORKSPACE_PRE}-$(date | md5 | cut -c 1-6)"
            echo "${TFE_WORKSPACE}" > tfe_workspace_name
            sed -e "s/tfe-workspace/${TFE_WORKSPACE}/" -e "s/tfe-org/${TFE_ORG}/" -e "s/app.terraform.io/${TFE_NAME}/" < backend.tf.example > backend.tf
            echo "bucket_name=\\"tf-test-bucket-$(date +%s)\\"" > terraform.auto.tfvars
            echo "aws_access_key = \\"${AWS_ACCESS_KEY_ID}\\"" >> terraform.auto.tfvars
            echo "aws_secret_key = \\"${AWS_SECRET_ACCESS_KEY}\\"" >> terraform.auto.tfvars
            sed -e "s/app.terraform.io/${TFE_NAME}/" -e  "s/tfe-token/${TFE_TOKEN}/" < terraformrc.example > ~/.terraformrc
            cat backend.tf
            cat terraform.auto.tfvars
            cat ~/.terraformrc
            '''
          }
      }
      
    stage('Terraform init') {
          steps {
            sh '''
            export PATH="/usr/local/bin:${PATH}"
            cd ${GIT_ROOT}/${WORKING_DIR}
            terraform init
            '''
          }
      }
      
      stage('Set workspace variables') {
          steps {
          sh '''
          export PATH="/usr/local/bin:${PATH}"
          cd ${GIT_ROOT}/${WORKING_DIR}
          curl -s https://raw.githubusercontent.com/kawsark/terraform-aws-s3-tests/master/api_templates/variable.template.json -o variable.template.json
          
          # Set bucket_name variable:
          export key="bucket_name"
          export value="tf-test-bucket-$(date +%s)"
          export TFE_WORKSPACE=$(cat tfe_workspace_name)
          sed -e "s/my-organization/${TFE_ORG}/" -e "s/my-workspace/${TFE_WORKSPACE}/" -e "s/my-key/${key}/" -e "s/my-value/${value}/" -e "s/my-category/terraform/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
          cat variable.json
          curl --header "Authorization: Bearer ${TFE_TOKEN}" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${TFE_NAME}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${TFE_ORG}&filter%5Bworkspace%5D%5Bname%5D=${TFE_WORKSPACE}"
          
          # Set CONFIRM_DESTROY variable:
          export key="CONFIRM_DESTROY"
          export value="1"
          sed -e "s/my-organization/${TFE_ORG}/" -e "s/my-workspace/${TFE_WORKSPACE}/" -e "s/my-key/${key}/" -e "s/my-value/${value}/" -e "s/my-category/env/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
          cat variable.json
          curl --header "Authorization: Bearer ${TFE_TOKEN}" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${TFE_NAME}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${TFE_ORG}&filter%5Bworkspace%5D%5Bname%5D=${TFE_WORKSPACE}"
          '''
          }
      }
      

      stage('Terraform apply') {
          steps {
            sh '''
            export PATH="/usr/local/bin:${PATH}"
            cd ${GIT_ROOT}/${WORKING_DIR}
            terraform apply --auto-approve
            '''
          }
      }
      
    }
    
    
}