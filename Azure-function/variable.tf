variable "vm_map" {
  type = map(object({
    name           = string
    size           = string
    admin_username = string
    admin_password = string
    location       = string
    repo_url       = string
    repo_dir       = string
    python_venv    = string
  }))
  
  default = {
    "vm1" = {
      name           = "Dev-app1"
      size           = "Standard_DS1_v2"
      admin_username = "chozhan1"
      admin_password = "Test1234"
      location       = "Central US"
      repo_url       = "https://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@github.com/Namachozhan/Terraform_check_Data_and_AI.git"
      repo_dir       = "C:\\cloned_repo1"
      python_venv    = "venv12"
    }
#    "vm2" = {
#      name           = "Dev-app2"
#      size           = "Standard_DS1_v2"
#      admin_username = "chozhan2"
#      admin_password = "Test1234"
#      location       = "Central US"
#      repo_url       = "https://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@github.com/Namachozhan/Terraform_check_Data_and_AI.git"
#      repo_dir       = "C:\\cloned_repo2"
#      python_venv    = "venv2"
#    }
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "EAIFBase"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "eaifdevopsvm1-vnet"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "default"
}
