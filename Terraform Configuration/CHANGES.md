# Module Changes

This document details the changes introduced in each module, building sequentially from the `pet_registry` starting configuration.

## Starting Point: `pet_registry`

The base configuration contains only the provider requirements and empty placeholder files.

- **terraform.tf**: Declares `hashicorp/random` (~> 3.0) and `hashicorp/local` (~> 2.0) as required providers
- **main.tf**: Empty
- **variables.tf**: Empty
- **outputs.tf**: Empty
- **prefix.txt**: Contains the static string `princess`

---

## Module 1: Resources and Data Sources

**Concepts introduced:** Resource blocks, data sources, resource arguments, implicit/explicit dependencies, file generation

### Changes from `pet_registry`

- **main.tf**:
  - Add `random_pet.cats` resource with `length = 2`, `separator = " "`, and `prefix` read from a data source
  - Add `random_pet.dogs` resource with `length = 3`, `separator = " "`, and an explicit `depends_on` referencing `random_pet.cats`
  - Add `local_file.cats` resource that writes the cat pet name to `cats.txt`
  - Add `local_file.dogs` resource that writes the dog pet name to `dogs.txt`
  - Add `data.local_file.prefix` data source that reads `prefix.txt` for use as the cat name prefix

---

## Module 2: Variables, Outputs, and Locals

**Concepts introduced:** Input variables, variable types (list), terraform.tfvars, output values, local values

### Changes from Module 1

- **main.tf**:
  - Add a `locals` block defining `separator = " "`
  - Change `random_pet.cats.separator` from a hardcoded string to `local.separator`
  - Change `random_pet.dogs.separator` from a hardcoded string to `local.separator`
  - Change `random_pet.cats.length` from hardcoded `2` to `var.pet_length[0]` (list index)
  - Change `random_pet.dogs.length` from hardcoded `3` to `var.pet_length[1]` (list index)
  - Replace the `data.local_file.prefix` data source (remains, still used for prefix)
- **variables.tf**:
  - Add `pet_length` variable of type `list(number)` with a description
- **terraform.tfvars** *(new file)*:
  - Set `pet_length = [3, 2]`
- **outputs.tf**:
  - Add `cats` output returning `random_pet.cats.id` with a description
  - Add `dogs` output returning `random_pet.dogs.id` with a description

---

## Module 3: Functions and Expressions

**Concepts introduced:** Built-in functions (`trimspace`, `file`, `templatefile`, `timestamp`, `title`), conditional expressions, template files, path references

### Changes from Module 2

- **main.tf**:
  - Replace `data.local_file.prefix` data source with inline `trimspace(file("prefix.txt"))` function call for the cat prefix
  - Remove the `data "local_file" "prefix"` block entirely
  - Add a conditional expression for `random_pet.dogs.prefix`: `var.add_dogs_prefix ? "king" : null`
  - Change `local_file.cats.content` from a simple string reference to a `templatefile()` call using `templates/pet_report.tpl`, passing `pets`, `timestamp`, and `type` variables
  - Change `local_file.dogs.content` from a simple string reference to a `templatefile()` call using the same template
- **variables.tf**:
  - Add `add_dogs_prefix` variable of type `bool` with `default = false`
- **terraform.tfvars**:
  - Add `add_dogs_prefix = true`
- **outputs.tf**:
  - Wrap both output values with the `title()` function for title-case formatting
- **templates/pet_report.tpl** *(new file in new directory)*:
  - Add a template that renders a pet report with a header, a table of pet names and lengths using a `for` directive, and a generated-on timestamp

---

## Module 4: Loops and Dynamic Blocks

**Concepts introduced:** `count` meta-argument, `for_each` meta-argument, `for` expressions in outputs, `dynamic` blocks, `map` variable type, `archive_file` resource, new provider

### Changes from Module 3

- **terraform.tf**:
  - Add `hashicorp/archive` (~> 2.0) to required providers
- **main.tf**:
  - Change `random_pet.cats` from a single resource to use `count = length(var.cat_lengths)` for multiple instances
  - Change `random_pet.cats.length` from `var.pet_length[0]` to `var.cat_lengths[count.index]`
  - Remove the conditional prefix expression on `random_pet.dogs`; change to use `for_each = var.dogs_info` with `each.key` as prefix and `each.value` as length
  - Update `local_file.cats` to pass the full `random_pet.cats` collection (tuple) to the template instead of wrapping a single resource in a list
  - Update `local_file.dogs` to pass the full `random_pet.dogs` collection (map) to the template instead of wrapping a single resource in a list
  - Add `archive_file.pet_registry` resource that zips `cats.txt` and `dogs.txt` using a `dynamic "source"` block iterating over the two local files
- **variables.tf**:
  - Rename `pet_length` to `cat_lengths` (type remains `list(number)`)
  - Replace `add_dogs_prefix` with `dogs_info` of type `map(number)` — keys are prefixes, values are lengths
- **terraform.tfvars**:
  - Replace `pet_length` with `cat_lengths = [2, 2]`
  - Remove `add_dogs_prefix`
  - Add `dogs_info` map with entries `"king" = 2` and `"queen" = 3`
- **outputs.tf**:
  - Change `cats` output to use a `for` expression iterating over `random_pet.cats` (returns a list of title-cased names)
  - Change `dogs` output to use a `for` expression iterating over `random_pet.dogs` (returns a list of title-cased names)

---

## Module 5: Validation and Lifecycle

**Concepts introduced:** `lifecycle` blocks, `precondition`, `postcondition`, input variable `validation` blocks, `startswith()` function, `contains()` function

### Changes from Module 4

- **main.tf**:
  - Remove the `locals` block (separator is now a variable)
  - Change `random_pet.cats.separator` from `local.separator` to `var.separator`
  - Change `random_pet.dogs.separator` from `local.separator` to `var.separator`
  - Add a `lifecycle` block with a `precondition` to `random_pet.cats` that validates each cat length is >= 2
  - Add a `lifecycle` block with a `postcondition` to `random_pet.dogs` that validates the pet name starts with the expected prefix using `startswith()`
- **variables.tf**:
  - Add `separator` variable of type `string` with `default = " "` and a `validation` block that restricts allowed values to `" "`, `"-"`, `":"`, `"+"` using `contains()`

---

## Module 6: Sensitive Data and Complex Types

**Concepts introduced:** `sensitive` variables, `sensitive` outputs, complex variable types (`map(string)`), additional template files, new resources consuming sensitive data

### Changes from Module 5

- **main.tf**:
  - Add `local_file.fosters` resource that uses `templatefile()` with a new `foster_parents_report.tpl` template, passing `var.foster_parents`
- **variables.tf**:
  - Add `foster_parents` variable of type `map(string)` marked as `sensitive = true`
- **terraform.tfvars**:
  - Add `foster_parents` map with entries `Alice = "Dog"`, `Bob = "Cat"`, `Charlie = "All"`
- **outputs.tf**:
  - Add `fosters` output that uses a `for` expression to extract foster parent names from `var.foster_parents`, marked as `sensitive = true`
- **templates/foster_parents_report.tpl** *(new file)*:
  - Add a template that renders a foster parents report listing each foster parent and their preferred pet type using a `for` directive
