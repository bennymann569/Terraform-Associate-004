# Google Cloud Remote Backend Setup

This configuration provisions the Google Cloud infrastructure needed to host
Terraform remote state in Google Cloud Storage (GCS):

- A versioned GCS bucket `tf-state-<project>-<suffix>`
- Uniform bucket-level access enabled
- Public access prevention enforced

The bucket name and a suggested state prefix are exported as the
`backend_info` output, which you can plug into a `gcs` backend block in
another Terraform configuration.

> The `gcs` backend implements state locking natively via GCS object
> generations — no extra resources are required.

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6.0
- [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install)
- A GCP project with the **Cloud Storage API** enabled and billing attached
- Permission to create storage buckets in the target project (e.g.
  `roles/storage.admin`)

---

## 1. Configure the gcloud CLI

Terraform's `google` provider reuses gcloud's Application Default Credentials
(ADC) by default.

### Sign in for user credentials (local development)

```pwsh
gcloud auth login
gcloud auth application-default login
```

The second command writes ADC to
`%APPDATA%\gcloud\application_default_credentials.json` (Windows) or
`~/.config/gcloud/application_default_credentials.json` (Linux/macOS), which
the Terraform provider picks up automatically.

### Set the default project

```pwsh
gcloud config set project <project-id>
gcloud auth application-default set-quota-project <project-id>
```

Verify:

```pwsh
gcloud auth list
gcloud config list
```

### Enable the Cloud Storage API (one-time)

```pwsh
gcloud services enable storage.googleapis.com
```

### Optional: use a service account

For CI or non-interactive use, create a service account, grant it permission,
and export a key:

```pwsh
gcloud iam service-accounts create terraform-state `
  --display-name "Terraform state"

gcloud projects add-iam-policy-binding <project-id> `
  --member "serviceAccount:terraform-state@<project-id>.iam.gserviceaccount.com" `
  --role "roles/storage.admin"

gcloud iam service-accounts keys create terraform-state.json `
  --iam-account "terraform-state@<project-id>.iam.gserviceaccount.com"
```

Then point Terraform at the key:

```pwsh
$env:GOOGLE_APPLICATION_CREDENTIALS = "$PWD\terraform-state.json"
```

> Treat the key file as a secret — keep it out of version control.

---

## 2. Provision the backend resources

From this directory (`Terraform State/remote_backend_setup/google`):

```pwsh
terraform init
terraform plan  -var "project_id=<project-id>"
terraform apply -var "project_id=<project-id>"
```

Or persist the value in a `terraform.tfvars` file:

```hcl
project_id = "my-gcp-project"
```

Review the plan and confirm with `yes`. On success the `backend_info` output
will look similar to:

```text
backend_info = {
  "bucket" = "tf-state-my-gcp-project-ab12cd34"
  "prefix" = "m2"
}
```

Capture those values — you'll reference them in the consumer configuration.

---

## 3. Use the bucket as a remote backend

In the Terraform configuration that should store its state remotely, add a
`gcs` backend block using the output values:

```hcl
terraform {
  backend "gcs" {
    bucket = "tf-state-my-gcp-project-ab12cd34" # backend_info.bucket
    prefix = "m2"                               # backend_info.prefix
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
contains state object versions. To tear down the backend infrastructure:

```pwsh
terraform destroy -var "project_id=<project-id>"
```

> Make sure no other configurations are still using the bucket as a backend
> before destroying it. Migrate their state to a local backend (or another
> remote backend) first with `terraform init -migrate-state`.
