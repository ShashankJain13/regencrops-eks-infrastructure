set -eo pipefail
export AWS_REGION=$AWS_REGION
# check if environment is prod branch is not main then exit
if [ "$ENVIRONMENT" == "prd" ] && [ "$BITBUCKET_BRANCH" != "main" ]; then
    echo "Invalid environment. For prod environment, branch should be main"
    exit 1
fi

# check if environment is dev  branch is main then exit
if [ "$ENVIRONMENT" == "dev" ] && [ "$BITBUCKET_BRANCH" == "main" ]; then
    echo "Invalid environment. For dev environment, branch should not be main"
    exit 1
fi

# check if environment is uat  branch is main then exit
if [ "$ENVIRONMENT" == "uat" ] && [ "$BITBUCKET_BRANCH" == "main" ]; then
    echo "Invalid environment. For uat environment, branch should not be main"
    exit 1
fi


# add if else condition of $ENVIRONMENT
if [ "$ENVIRONMENT" == "dev" ]; then
    export AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID_DEV
    export AWS_ROLE_ARN=$AWS_ROLE_ARN_DEV
    export TERRAFORM_STATE_S3_BUCKET=$TERRAFORM_STATE_S3_BUCKET_DEV
    export LOCK_TABLE=$LOCK_TABLE_DEV
elif [ "$ENVIRONMENT" == "uat" ]; then
    export AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID_UAT
    export AWS_ROLE_ARN=$AWS_ROLE_ARN_UAT
    export TERRAFORM_STATE_S3_BUCKET=$TERRAFORM_STATE_S3_BUCKET_UAT
    export LOCK_TABLE=$LOCK_TABLE_UAT
elif [ "$ENVIRONMENT" == "prd" ]; then
    export AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID_PRD
    export AWS_ROLE_ARN=$AWS_ROLE_ARN_PRD
    export TERRAFORM_STATE_S3_BUCKET=$TERRAFORM_STATE_S3_BUCKET_PRD
    export LOCK_TABLE=$LOCK_TABLE_PRD
else
    echo "Invalid environment. Valid values are dev, uat, prd"
    exit 1
fi

export AWS_WEB_IDENTITY_TOKEN_FILE=$(pwd)/web-identity-token
echo $BITBUCKET_STEP_OIDC_TOKEN > $(pwd)/web-identity-token
cd $BITBUCKET_CLONE_DIR/$CONFIGURATION_DIRECTORY
mkdir -p plan_dir
state_key=${BITBUCKET_PROJECT_KEY}/${BITBUCKET_REPO_SLUG}/${BITBUCKET_BRANCH}/${CONFIGURATION_DIRECTORY}/${AWS_ACCOUNT_ID}/${ENVIRONMENT}-terraform.tfstate
terraform init -backend-config="bucket=${TERRAFORM_STATE_S3_BUCKET}" -backend-config="key=${state_key}" -backend-config="region=${AWS_REGION}" -backend-config="dynamodb_table=${LOCK_TABLE}" -backend-config="encrypt=true"

echo "Terraform backend configuration :- "
echo "AWS_ROLE_ARN      - ${AWS_ROLE_ARN}"
echo "region            - ${AWS_REGION}"
echo "s3 bucket         - ${TERRAFORM_STATE_S3_BUCKET}"
echo "state key         - ${state_key}"
echo "dynamodb table    - ${LOCK_TABLE}"
echo "encrypt           - true"

TERRAFORM_ACTION="$1"
if [ "$TERRAFORM_ACTION" == "PLAN" ]; then
    echo "Running terraform plan"
    terraform plan -var-file=$BITBUCKET_CLONE_DIR/$CONFIGURATION_DIRECTORY/env/ENV-$ENVIRONMENT.tfvars -out=plan_dir/tfplan_file.txt
    if [ $? -ne 0 ]; then
        echo "Terraform plan failed"
        exit 1
    fi
    echo "Terraform plan completed"
elif [ "$TERRAFORM_ACTION" == "APPLY" ]; then
    echo "Running terraform apply"
    terraform plan -var-file=$BITBUCKET_CLONE_DIR/$CONFIGURATION_DIRECTORY/env/ENV-$ENVIRONMENT.tfvars -out=plan_dir/tfplan_file.txt
    if [ $? -ne 0 ]; then
        echo "Terraform plan failed"
        exit 1
    fi
    terraform apply -auto-approve $BITBUCKET_CLONE_DIR/$CONFIGURATION_DIRECTORY/plan_dir/tfplan_file.txt
    if [ $? -ne 0 ]; then
        echo "Terraform apply failed"
        exit 1
    fi
    echo "Terraform apply completed"
elif [ "$TERRAFORM_ACTION" == "DESTROY_PLAN" ]; then
    echo "Running terraform destroy plan"
    terraform plan -destroy -var-file=$BITBUCKET_CLONE_DIR/$CONFIGURATION_DIRECTORY/env/ENV-$ENVIRONMENT.tfvars -out=plan_dir/tfplan_file.txt
    if [ $? -ne 0 ]; then
        echo "Terraform destroy plan failed"
        exit 1
    fi
    echo "Terraform destroy plan completed"
elif [ "$TERRAFORM_ACTION" == "DESTROY" ]; then
    echo "Running terraform destroy"
    terraform plan -destroy -var-file=$BITBUCKET_CLONE_DIR/$CONFIGURATION_DIRECTORY/env/ENV-$ENVIRONMENT.tfvars -out=$BITBUCKET_CLONE_DIR/$CONFIGURATION_DIRECTORY/tfplan_file.txt
    if [ $? -ne 0 ]; then
        echo "Terraform destroy plan failed"
        exit 1
    fi
    terraform destroy -auto-approve -var-file=$BITBUCKET_CLONE_DIR/$CONFIGURATION_DIRECTORY/env/ENV-$ENVIRONMENT.tfvars
    if [ $? -ne 0 ]; then
        echo "Terraform destroy failed"
        exit 1
    fi
    echo "Terraform destroy completed"
elif [ "$TERRAFORM_ACTION" == "IMPORT" ]; then
    echo "Running terraform import"
    RESOURCE_TYPE="$2"
    RESOURCE_ID="$3"
    if [ -z "$RESOURCE_TYPE" ] || [ -z "$RESOURCE_ID" ]; then
        echo "Invalid inputs. RESOURCE_TYPE and RESOURCE_ID cannot be empty."
        exit 1
    fi
    terraform import -var-file=$BITBUCKET_CLONE_DIR/$CONFIGURATION_DIRECTORY/env/ENV-$ENVIRONMENT.tfvars $RESOURCE_TYPE $RESOURCE_ID
    if [ $? -ne 0 ]; then
        echo "Terraform Import failed"
        exit 1
    fi
    echo "Terraform import completed"
else
    echo "Invalid terraform action"
fi
