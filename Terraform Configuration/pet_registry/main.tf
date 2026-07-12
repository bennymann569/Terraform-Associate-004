locals {
  separator = tolist(["-", "_"," "])
}

resource "random_pet" "cats" {
  length    = var.length[0]
  separator = local.separator[0]
  prefix    = data.local_file.prefix.content
}

resource "random_pet" "dogs" {
  length    = var.length[1]
  separator = local.separator[1]
  depends_on = [random_pet.cats]
}

resource "local_file" "cats" {
  filename = "cats.txt"
  content  = random_pet.cats.id
}

resource "local_file" "dogs" {
  filename = "dogs.txt"
  content  = random_pet.dogs.id
}

data "local_file" "prefix" {
  filename = "prefix.txt"
}