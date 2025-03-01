variable "app_name" {
  default     = "glue-poc"
  description = "The name of the application"
  type        = string
}

variable "db_username" {
  default = "admin"
  type    = string
}
variable "db_password" {
  default = "password123"
  type    = string
}

variable "db_name" {
  default = "db"
  type    = string
}
