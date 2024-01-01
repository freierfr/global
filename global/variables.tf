variable "env" {
  type = string
  default = "prd"
}

variable "location" {
  type = string
  default = "westeurope"
}

variable "bluesky_users" {
  type = list(list(string))
}
