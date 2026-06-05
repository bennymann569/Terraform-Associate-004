#requires -Version 5.1
<#
.SYNOPSIS
    Creates an S3 bucket with a unique name and returns the bucket name.

.DESCRIPTION
    Generates a globally-unique S3 bucket name using a prefix plus a short
    random suffix, creates the bucket in the specified AWS region using the
    AWS CLI, and writes the bucket name to stdout so it can be captured by
    a caller (e.g. for use in a Terraform `import` block).

.PARAMETER Prefix
    Prefix for the bucket name. Must be DNS-compliant (lowercase letters,
    digits, hyphens). Defaults to "tf-import-demo".

.PARAMETER Region
    AWS region in which to create the bucket. Defaults to "us-east-2".

.PARAMETER Profile
    Optional AWS CLI named profile to use.

.EXAMPLE
    PS> ./create-bucket.ps1
    tf-import-demo-a1b2c3d4

.EXAMPLE
    PS> $bucket = ./create-bucket.ps1 -Prefix "my-demo" -Region "us-west-2"
    PS> $bucket
    my-demo-9f8e7d6c
#>
[CmdletBinding()]
param(
    [ValidatePattern('^[a-z0-9]([a-z0-9-]{1,30}[a-z0-9])?$')]
    [string]$Prefix = 'tf-import-demo',

    [string]$Region = 'us-east-2',

    [string]$Profile
)

$ErrorActionPreference = 'Stop'

# Ensure the AWS CLI is available.
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    throw "AWS CLI ('aws') was not found in PATH. Install it from https://aws.amazon.com/cli/."
}

# Build a common argument array so we can optionally include --profile.
$commonArgs = @('--region', $Region)
if ($PSBoundParameters.ContainsKey('Profile') -and $Profile) {
    $commonArgs += @('--profile', $Profile)
}

# Generate an 8-character lowercase-hex suffix for uniqueness.
$suffix = -join ((1..8) | ForEach-Object {
    '{0:x}' -f (Get-Random -Minimum 0 -Maximum 16)
})
$bucketName = "$Prefix-$suffix"

# S3 bucket names must be 3-63 chars.
if ($bucketName.Length -gt 63) {
    throw "Generated bucket name '$bucketName' exceeds 63 characters. Use a shorter -Prefix."
}

Write-Verbose "Creating S3 bucket '$bucketName' in region '$Region'..."

# us-east-1 must NOT receive a LocationConstraint; every other region requires one.
$createArgs = @('s3api', 'create-bucket', '--bucket', $bucketName) + $commonArgs
if ($Region -ne 'us-east-1') {
    $createArgs += @('--create-bucket-configuration', "LocationConstraint=$Region")
}

# Invoke the AWS CLI. Suppress stdout (CLI prints the Location) and rely on $LASTEXITCODE.
$null = & aws @createArgs 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Failed to create S3 bucket '$bucketName' (aws exit code $LASTEXITCODE)."
}

# Emit only the bucket name on stdout so callers can capture it cleanly.
$bucketName
