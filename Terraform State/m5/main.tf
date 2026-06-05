resource "random_pet" "llama" {
  length    = 3
  separator = " "
}

resource "local_file" "llama" {
  content  = random_pet.llama.id
  filename = "${path.module}/llama.txt"
}

output "llama_name" {
  value = random_pet.llama.id
}