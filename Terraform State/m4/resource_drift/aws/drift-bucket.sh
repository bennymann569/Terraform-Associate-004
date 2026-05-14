#!/usr/bin/env bash
# Updates the S3 bucket tags out-of-band to simulate resource drift.
# Sets Environment=Production and adds Drift=True.

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

echo "Updating tags on bucket: $bucket_name ($bucket_region)"

aws s3api put-bucket-tagging \
    --region "$bucket_region" \
    --bucket "$bucket_name" \
    --tagging 'TagSet=[{Key=Environment,Value=Production},{Key=Drift,Value=True}]'

echo "Tags updated. Current tagging:"
aws s3api get-bucket-tagging --region "$bucket_region" --bucket "$bucket_name"
