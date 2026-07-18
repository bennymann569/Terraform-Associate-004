variable "length" {
  description = "The length of the random pet name"
  type        = list(number)
}

variable "add_dogs_prefix" {
  description = "add dogs prefix"
  type = bool
  default = false
}