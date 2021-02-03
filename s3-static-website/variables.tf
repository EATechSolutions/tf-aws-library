variable "project_name" {
  type = string
  description = "the name of the project"
}

variable "env" {
  type = string
  description = "Environment"
  default = "dev"
}