# AWS Remote Backend Setup

This configuration provisions the AWS infrastructure needed to host Terraform
remote state in S3:

- A versioned S3 bucket with a random `tf-state-` prefix
- Server-side encryption (AES256) enabled on the bucket

The resulting bucket name, region, and a suggested state key are exported as the
`bucket_info` output, which you can plug into an `s3` backend block in another
Terraform configuration.

> S3 native state locking (the `use_lockfile = true` backend option introduced
> in Terraform 1.10) is used by the consuming configuration, so no DynamoDB
> table is required here.

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6.0
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- An AWS account and an IAM user (or SSO role) with permission to create S3
  buckets in the target region (`us-east-2` by default)

---

## 1. Configure the AWS CLI

Terraform's AWS provider reads credentials from the same sources as the AWS
CLI. The simplest path is to create a named profile with `aws configure`.

### Option A: Static IAM user access keys

1. In the AWS Console, go to **IAM → Users → *your user* → Security
   credentials** and create a new access key for CLI use.
2. Run the configuration wizard:

   ```pwsh
   aws configure --profile terraform
   ```

   Provide the values when prompted:

   ```text
   AWS Access Key ID [None]: AKIA...
   AWS Secret Access Key [None]: ****
   Default region name [None]: us-east-2
   Default output format [None]: json
   ```

   This writes credentials to `~/.aws/credentials` and config to `~/.aws/config`.

3. Verify the profile works:

   ```pwsh
   aws sts get-caller-identity --profile terraform
   ```

### Option B: AWS IAM Identity Center (SSO)

If your organization uses IAM Identity Center:

```pwsh
aws configure sso --profile terraform
aws sso login --profile terraform
```

### Tell Terraform which profile to use

Export the profile (and optionally region) before running Terraform so the
provider picks them up:

```pwsh
$env:AWS_PROFILE = "terraform"
$env:AWS_REGION  = "us-east-2"
```

For Bash/WSL:

```bash
export AWS_PROFILE=terraform
export AWS_REGION=us-east-2
```

Confirm Terraform can authenticate:

```pwsh
aws sts get-caller-identity
```

---

## 2. Provision the backend resources

From this directory (`Terraform State/remote_backend_setup/aws`):

```pwsh
terraform init
terraform plan
terraform apply
```

Review the plan and confirm with `yes`. On success, the `bucket_info` output
will look similar to:

```text
bucket_info = {
  "bucket_name" = "tf-state-20260511123456789000000001"
  "key"         = "m2/terraform.tfstate"
  "region"      = "us-east-2"
}
```

Capture those values — you'll reference them in the consumer configuration.

---

## 3. Use the bucket as a remote backend

In the Terraform configuration that should store its state remotely, add an
`s3` backend block using the output values:

```hcl
terraform {
  backend "s3" {
    bucket       = "tf-state-20260511123456789000000001" # bucket_info.bucket_name
    key          = "m2/terraform.tfstate"                # bucket_info.key
    region       = "us-east-2"                           # bucket_info.region
    encrypt      = true
    use_lockfile = true
  }
}
```

Then migrate (or initialize) state:

```pwsh
terraform init -migrate-state
```

---

## 4. Clean up

`force_destroy = true` is set on the bucket so it can be removed even when it
contains state versions. To tear down the backend infrastructure:

```pwsh
terraform destroy
```

> Make sure no other configurations are still using the bucket as a backend
> before destroying it. Migrate their state to a local backend (or another
> remote backend) first with `terraform init -migrate-state`.
