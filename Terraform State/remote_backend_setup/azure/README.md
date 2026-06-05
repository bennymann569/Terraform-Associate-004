# Azure Remote Backend Setup

This configuration provisions the Azure infrastructure needed to host
Terraform remote state in Azure Blob Storage:

- A resource group `rg-tf-state-<suffix>`
- A Standard LRS storage account `tfstate<suffix>` with blob versioning and
  TLS 1.2 enforced
- A private blob container named `tfstate`

The resource group, storage account, container, and a suggested state key are
exported as the `backend_info` output, which you can plug into an `azurerm`
backend block in another Terraform configuration.

> The `azurerm` backend uses blob leases for state locking automatically — no
> extra resources are required.

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6.0
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- An Azure subscription where you can create resource groups and storage
  accounts

---

## 1. Configure the Azure CLI

Terraform's `azurerm` provider reuses the Azure CLI's authentication by
default.

### Sign in

```pwsh
az login
```

A browser window opens for interactive sign-in. For headless environments use
`az login --use-device-code`.

### Select the target subscription

List available subscriptions and set the active one:

```pwsh
az account list --output table
az account set --subscription "<subscription-id-or-name>"
```

Verify:

```pwsh
az account show
```

### Optional: use a service principal

For CI or non-interactive use, create a service principal and export its
credentials:

```pwsh
az ad sp create-for-rbac --name "terraform-state" --role "Contributor" `
  --scopes "/subscriptions/<subscription-id>"
```

Then set the environment variables Terraform's `azurerm` provider reads:

```pwsh
$env:ARM_CLIENT_ID       = "<appId>"
$env:ARM_CLIENT_SECRET   = "<password>"
$env:ARM_TENANT_ID       = "<tenant>"
$env:ARM_SUBSCRIPTION_ID = "<subscription-id>"
```

---

## 2. Provision the backend resources

From this directory (`Terraform State/remote_backend_setup/azure`):

```pwsh
terraform init
terraform plan
terraform apply
```

Review the plan and confirm with `yes`. On success the `backend_info` output
will look similar to:

```text
backend_info = {
  "container_name"       = "tfstate"
  "key"                  = "m2/terraform.tfstate"
  "resource_group_name"  = "rg-tf-state-ab12cd34"
  "storage_account_name" = "tfstateab12cd34"
}
```

Capture those values — you'll reference them in the consumer configuration.

---

## 3. Use the storage account as a remote backend

In the Terraform configuration that should store its state remotely, add an
`azurerm` backend block using the output values:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-state-ab12cd34" # backend_info.resource_group_name
    storage_account_name = "tfstateab12cd34"      # backend_info.storage_account_name
    container_name       = "tfstate"              # backend_info.container_name
    key                  = "m2/terraform.tfstate" # backend_info.key
  }
}
```

Then migrate (or initialize) state:

```pwsh
terraform init -migrate-state
```

---

## 4. Clean up

To tear down the backend infrastructure:

```pwsh
terraform destroy
```

> Make sure no other configurations are still using the storage account as a
> backend before destroying it. Migrate their state to a local backend (or
> another remote backend) first with `terraform init -migrate-state`.
