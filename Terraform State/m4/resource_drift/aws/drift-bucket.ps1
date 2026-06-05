# Updates the S3 bucket tags out-of-band to simulate resource drift.
# Sets Environment=Production and adds Drift=True.

$ErrorActionPreference = 'Stop'

# Get the bucket name and region from the Terraform outputs
$bucketName = terraform output -raw bucket_name
if ([string]::IsNullOrWhiteSpace($bucketName)) {
    throw "Could not read 'bucket_name' output from Terraform."
}

$bucketRegion = terraform output -raw bucket_region
if ([string]::IsNullOrWhiteSpace($bucketRegion)) {
    throw "Could not read 'bucket_region' output from Terraform."
}

Write-Host "Updating tags on bucket: $bucketName ($bucketRegion)"

aws s3api put-bucket-tagging `
    --region $bucketRegion `
    --bucket $bucketName `
    --tagging 'TagSet=[{Key=Environment,Value=Production},{Key=Drift,Value=True}]'

Write-Host "Tags updated. Current tagging:"
aws s3api get-bucket-tagging --region $bucketRegion --bucket $bucketName
