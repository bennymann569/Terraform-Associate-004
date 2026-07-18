locals {
  separator = tolist(["-", "_"," "])
}

resource "random_pet" "cats" {
  length    = var.length[0]
  separator = local.separator[0]
  prefix    = trimspace(file("prefix.txt"))
}

resource "random_pet" "dogs" {
  length    = var.length[1]
  separator = local.separator[1]
  depends_on = [random_pet.cats]
  prefix    = var.add_dogs_prefix ? "king" : null
}

resource "local_file" "cats" {
  filename = "cats.txt"
  content  = templatefile("./templates/pet_report.tpl",
  {
    pets = [random_pet.cats]
    timestamp = timestamp()
    type = "cats"
  })
}

resource "local_file" "dogs" {
  filename = "dogs.txt"
  content  = templatefile("./templates/pet_report.tpl",
  {
    pets = [random_pet.dogs]
    timestamp = timestamp()
    type = "dogs"
  })
}