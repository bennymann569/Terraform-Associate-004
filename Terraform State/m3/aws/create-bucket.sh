#!/usr/bin/env bash
#
# create-bucket.sh
#
# Creates an S3 bucket with a unique name and prints the bucket name to stdout
# so a caller can capture it (e.g. for use in a Terraform `import` block).
#
# Usage:
#   ./create-bucket.sh [-p PREFIX] [-r REGION] [-P AWS_PROFILE]
#
# Options:
#   -p PREFIX       Bucket name prefix (default: tf-import-demo).
#                   Must be DNS-compliant: lowercase letters, digits, hyphens.
#   -r REGION       AWS region (default: us-east-2).
#   -P AWS_PROFILE  Optional AWS CLI named profile.
#   -h              Show this help.
#
# Examples:
#   bucket=$(./create-bucket.sh)
#   bucket=$(./create-bucket.sh -p my-demo -r us-west-2)

set -euo pipefail

prefix="tf-import-demo"
region="us-east-2"
profile=""

usage() {
    sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'
}

while getopts ":p:r:P:h" opt; do
    case "$opt" in
        p) prefix="$OPTARG" ;;
        r) region="$OPTARG" ;;
        P) profile="$OPTARG" ;;
        h) usage; exit 0 ;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage >&2; exit 2 ;;
        :)  echo "Option -$OPTARG requires an argument." >&2; exit 2 ;;
    esac
done

# Validate prefix (DNS-compliant, 3-32 chars to leave room for the suffix).
if ! [[ "$prefix" =~ ^[a-z0-9]([a-z0-9-]{1,30}[a-z0-9])?$ ]]; then
    echo "Invalid -p PREFIX '$prefix'. Use lowercase letters, digits, and hyphens." >&2
    exit 2
fi

# Ensure the AWS CLI is available.
if ! command -v aws >/dev/null 2>&1; then
    echo "AWS CLI ('aws') was not found in PATH. Install it from https://aws.amazon.com/cli/." >&2
    exit 1
fi

# Generate an 8-character lowercase-hex suffix for uniqueness.
if command -v openssl >/dev/null 2>&1; then
    suffix=$(openssl rand -hex 4)
else
    # Fallback using /dev/urandom.
    suffix=$(LC_ALL=C tr -dc 'a-f0-9' </dev/urandom | head -c 8)
fi

bucket_name="${prefix}-${suffix}"

# S3 bucket names must be 3-63 chars.
if (( ${#bucket_name} > 63 )); then
    echo "Generated bucket name '$bucket_name' exceeds 63 characters. Use a shorter -p PREFIX." >&2
    exit 1
fi

# Build the common AWS CLI arg list.
common_args=(--region "$region")
if [[ -n "$profile" ]]; then
    common_args+=(--profile "$profile")
fi

echo "Creating S3 bucket '$bucket_name' in region '$region'..." >&2

# us-east-1 must NOT receive a LocationConstraint; every other region requires one.
create_args=(s3api create-bucket --bucket "$bucket_name" "${common_args[@]}")
if [[ "$region" != "us-east-1" ]]; then
    create_args+=(--create-bucket-configuration "LocationConstraint=$region")
fi

if ! aws "${create_args[@]}" >/dev/null; then
    echo "Failed to create S3 bucket '$bucket_name'." >&2
    exit 1
fi

# Emit only the bucket name on stdout so callers can capture it cleanly.
echo "$bucket_name"
