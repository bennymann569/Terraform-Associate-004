variable "cat_length" {
  description = "The length of the random cat name"
  type        = list(number)
}

variable "dogs_info" {
  description = "Map of dog prefixes to lengths"
  type        = map(number)
}

variable "separator" {
  description = "The separator to use in the random pet names"
  type        = list(string)
  default     = ["-", "_", " "]

validation {
  condition = alltrue([
    for s in var.separator : contains(["-", "_", " "], s)
  ])
  error_message = "Each separator must be '-', '_' or ' '."
}
}