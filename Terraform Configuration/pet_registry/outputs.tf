output "cats_id" {
  value = random_pet.cats.id
}

output "dogs_id" {
  value = random_pet.dogs.id
}

output "cats_file" {
  value = local_file.cats.filename
}

output "dogs_file" {
  value = local_file.dogs.filename
}