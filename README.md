# DoS Test Database

## Quick Deploy (WIP)

This assumes you've MFA-ed to get and set your AWS CLI credentials

### With Terraform

    cd infrastructure/stacks/service

The directory where to run the terraform commands from

#### Initialize Terraform State

    terraform init \
                -backend-config="bucket=nhsd-texasplatform-terraform-service-state-store-lk8s-nonprod" \
                -backend-config="dynamodb_table=nhsd-texasplatform-terraform-service-state-lock-texas-lk8s-nonprod" \
                -backend-config="encrypt=true" \
                -backend-config="key=uec-dos-test-database-service-local/terraform.state" \
                -backend-config="region=eu-west-2"

Run this to setup your terraform state in a AWS S3 bucket in AWS (TEXAS)

#### Plan Terraform

    terraform plan --var-file=../tfvars/nonprod.tfvars

Run this to see what effects this will have on your infrastructure

#### Apply Terraform

    terraform apply --var-file=../tfvars/nonprod.tfvars

Run this to see what effect this will have on the infrastructure and entering 'yes' at the end will APPLY this to your AWS (TEXAS) infrastructure (use caution)

#### Destroy Terraform

    terraform destroy --var-file=../tfvars/nonprod.tfvars

Run this to see what would be deleted from the infrastructure and entering 'yes' at the end will DELETE the resources from your AWS (TEXAS) infrastructure (use caution)

### With Make DevOps Targets

Running the follow from the project root

#### Initialize Terraform State & Plan

    make terraform-plan STACKS=service OPTS="--var-file=infrastructure/stacks/tfvars/nonprod.tfvars"

Run this to initialize the terraform state and place it in S3, and then run a terraform plan

#### Apply Terraform with Make Target

    make terraform-apply STACKS=service OPTS="--var-file=infrastructure/stacks/tfvars/nonprod.tfvars"

Run this to see what effect this will have on the infrastructure and entering 'yes' at the end will APPLY this to your AWS (TEXAS) infrastructure (use caution)

#### Destroy Terraform with Make Target

    make terraform-destroy STACKS=service OPTS="--var-file=infrastructure/stacks/tfvars/nonprod.tfvars"

Run this to see what would be deleted from the infrastructure and entering 'yes' at the end will DELETE the resources from your AWS (TEXAS) infrastructure (use caution)
