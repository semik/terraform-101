#!/bin/bash

# set the subscription
export ARM_SUBSCRIPTION_ID="e4ea7e96-4993-4602-bc68-0c202688b32f"

# set the application / environemnt
export TF_VAR_application_name="devops"
export TF_VAR_environment_name="prod"

# set the backnend
export BACKEND_RESOURCE_GROUP="rg-terraform-state-prod"
export BACKEND_STORAGE_ACCOUNT="stg4e3ra7lka"
export BACKEND_CONTAINER="tfstate"
export BACKEND_KEY="${TF_VAR_application_name}-${TF_VAR_environment_name}"

#run terraform
tofu init \
    -backend-config="resource_group_name=${BACKEND_RESOURCE_GROUP}" \
    -backend-config="storage_account_name=${BACKEND_STORAGE_ACCOUNT}" \
    -backend-config="container_name=${BACKEND_CONTAINER}" \
    -backend-config="key=${BACKEND_KEY}"

tofu $*
rm -rf .terraform