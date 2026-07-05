resource "random_string" "main" {
  length  = var.string_length
  special = "true"
}

resource "local_file" "main" {
  filename        = var.file_name
  content         = random_string.main.result
  file_permission = "111"
}