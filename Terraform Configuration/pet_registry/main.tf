locals {
  separator = tolist(["-", "_"," "])
}

resource "random_pet" "cats" {
  count    = length(var.cat_length)
  length    = var.cat_length[count.index]
  separator = local.separator[0]
  prefix    = trimspace(file("prefix.txt"))
}

resource "random_pet" "dogs" {
  for_each = var.dogs_info
  length    = each.value
  separator = local.separator[1]
  depends_on = [random_pet.cats]
  prefix    = each.key
}

resource "local_file" "cats" {
  filename = "cats.txt"
  content  = templatefile("./templates/pet_report.tpl",
  {
    pets = random_pet.cats
    timestamp = timestamp()
    type = "cats"
  })
}

resource "local_file" "dogs" {
  filename = "dogs.txt"
  content  = templatefile("./templates/pet_report.tpl",
  {
    pets = random_pet.dogs
    timestamp = timestamp()
    type = "dogs"
  })
}

resource "archive_file" "pet_registry" {
  type        = "zip"
  output_path = "pet_registry.zip"

  dynamic "source" {
    for_each = [local_file.cats, local_file.dogs]
    content {
      content  = source.value.content
      filename = source.value.filename
    }
  }
}