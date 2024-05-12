variable "rg_name" {
  default = "peering-rg"
}

variable "rg_location" {
  default = "eastus"
}

variable "vnet_name" {
  default = "vnet"
}

variable "vnet_count" {
  default = 2
}

variable "vnet_address_space" {
  default = [
    "10.0.0.0/16",
    "10.1.0.0/16",
  ]
}

variable "subnet_address_space" {
  default = [
    ["10.0.0.0/24"],
    ["10.1.0.0/24"],
  ]
}

variable "vm_count" {
  default = 0
}

variable "disk_count" {
  default = 2
}