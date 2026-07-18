output "cats_id" {
  value = title(random_pet.cats.id)
}

output "dogs_id" {
  value = title(random_pet.dogs.id)
}
