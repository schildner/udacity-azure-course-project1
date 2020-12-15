variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "udacity-azure-course-project1-iac"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "westeurope"
}

variable "username" {
  description = "The VM users name."
  default = "eduard"
}

variable "password" {
  description = "The VM users password:"
  sensitive = true
}

variable "number_of_vms" {
  description = "The number of Virtual Machines to be deployed."
  type        = number
  default     = "2"
}

variable "packer_image" {
  description = "The ID of the image created by packer tool."
  default = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/images/Ubuntu1804Image"
}

variable "subscription" {
  description = "The subscription for which the resources are going to be deployed."
  default = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef"
}