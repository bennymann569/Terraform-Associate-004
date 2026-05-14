#!/usr/bin/env bash
# Updates the S3 bucket request payer to simulate state drift on an
# unmanaged attribute.

set -euo pipefail

# Get the bucket name and region from the Terraform outputs
bucket_name=$(terraform output -raw bucket_name)
if [[ -z "$bucket_name" ]]; then
    echo "Could not read 'bucket_name' output from Terraform." >&2
    exit 1
fi

bucket_region=$(terraform output -raw bucket_region)
if [[ -z "$bucket_region" ]]; then
    echo "Could not read 'bucket_region' output from Terraform." >&2
    exit 1
fi

echo "Setting request payer to 'Requester' on bucket: $bucket_name ($bucket_region)"

aws s3api put-bucket-request-payment \
    --region "$bucket_region" \
    --bucket "$bucket_name" \
    --request-payment-configuration 'Payer=Requester'

echo "Current request payment configuration:"
aws s3api get-bucket-request-payment --region "$bucket_region" --bucket "$bucket_name"
