variable "vm_map" {
  type = map(object({
    name           = string
    size           = string
    location       = string
  }))
  
  default = {
    "vm1" = {
      name           = "Dev-app1"
      size           = "Standard_DS1_v2"
      location       = "Central US"
    }
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "EAIFDEVOPSRG"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "DevOpsVM-1-vnet"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "default"
}

variable "admin_username" {
  description = "The name of the admin_username"
  type        = string
  default     = "chozhan1"
}
 
variable "admin_password" {
  description = "The name of the admin_password"
  type        = string
  default     = "Test1234"
}
