variable "cat_length" {
  description = "The length of the random cat name"
  type        = list(number)
}

variable "dogs_info" {
  description = "Map of dog prefixes to lengths"
  type        = map(number)
}