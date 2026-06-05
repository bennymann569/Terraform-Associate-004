# Updates the S3 bucket request payer to simulate state drift on an
# unmanaged attribute.

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

Write-Host "Setting request payer to 'Requester' on bucket: $bucketName ($bucketRegion)"

aws s3api put-bucket-request-payment `
    --region $bucketRegion `
    --bucket $bucketName `
    --request-payment-configuration 'Payer=Requester'

Write-Host "Current request payment configuration:"
aws s3api get-bucket-request-payment --region $bucketRegion --bucket $bucketName
