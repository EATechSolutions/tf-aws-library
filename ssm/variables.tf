variable "parameters" {
  type        = map
  description = "List of SSM Parameters with format: { name, type, value }"
}

variable "application_name" {
  type = string
}

variable "environment" {
  type = string
}