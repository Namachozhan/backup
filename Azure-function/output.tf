# Output Public IP Address
output "public_ip_address" {
  value = { for key, ip in azurerm_public_ip.example : key => ip.ip_address }
}


# Output Resource Group Name

# Output VM ID
output "vm_id" {
  value = { for key, vm in azurerm_windows_virtual_machine.example : key => vm.id }
}

