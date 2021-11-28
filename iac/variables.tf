variable "token" {}
variable "public_key" {}
variable "private_key" {}
variable "email" {}
variable "api_key" {}
variable "zone_id" {}
variable "zone_name" {}

resource "random_string" "password" {
  length = 32
  special = true
  upper = true
  lower = true
  number = true
}
