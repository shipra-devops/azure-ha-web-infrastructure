variable "resource_group_name" {
  default = "rg-network-lab"
}
variable "location" {
  default = "westus"
}

variable "vnet_name" {
  default = "vnet-prod"
}

variable "admin_username" {
  default = "azureuser"
}

variable "vm_size" {
  default = "Standard_B1s"
}

variable "admin_password" {
  sensitive = true
}