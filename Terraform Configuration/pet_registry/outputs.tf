output "cats_id" {
  description = "The list of random cat names (TUPLE)"
  value       = [for cat in random_pet.cats : title(cat.id)]
}

output "dogs_id" {
  description = "The list of random dog names (TUPLE)"
  value       = [for dog in random_pet.dogs : title(dog.id)]
}
