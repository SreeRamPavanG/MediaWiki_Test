variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "testtwmediawiki"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "South Central US"
}

variable "vm_size" {
  description = "VM size"
  default = "Standard_B2s"
}

variable "storage_account_type" {
  default = "Standard_LRS"
}

variable "vm_username" {
  description = "The username for accessing the virtual machine."
  type        = string
}

variable "vm_password" {
  description = "The password for accessing the virtual machine."
  type        = string
}

variable "keyvault_name" {
  description = "The name of the Azure Key Vault used for storing secrets."
  type        = string
}

variable "storage_name" {
  description = "The name of the Azure Storage Account used for storing Terraform state files."
  type        = string
}
