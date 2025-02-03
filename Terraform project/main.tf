# Data Resources for Resource Group and Subnet
data "azurerm_resource_group" "test" {
  name = var.resource_group_name
}

data "azurerm_subnet" "test" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

# Public IP address for external access
resource "azurerm_public_ip" "example" {
  for_each = var.vm_map

  name                = "${each.value.name}-public-ip"
  location            = each.value.location
  resource_group_name = data.azurerm_resource_group.test.name
  allocation_method   = "Static"
}

# Network Security Group (NSG)
resource "azurerm_network_security_group" "example" {
  for_each = var.vm_map

  name                = "${each.value.name}-nsg"
  location            = each.value.location
  resource_group_name = data.azurerm_resource_group.test.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "WinRM"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "example" {
  for_each = var.vm_map

  name                = "${each.value.name}-nic"
  location            = each.value.location
  resource_group_name = data.azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example[each.key].id
  }
}

# Associate NSG with Network Interface
resource "azurerm_network_interface_security_group_association" "example" {
  for_each = var.vm_map

  network_interface_id      = azurerm_network_interface.example[each.key].id
  network_security_group_id = azurerm_network_security_group.example[each.key].id
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "example" {
  for_each = var.vm_map

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = each.value.location
  size                = each.value.size
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password

  network_interface_ids = [
    azurerm_network_interface.example[each.key].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.example,
    azurerm_network_interface_security_group_association.example
  ]
}

# Custom Script Extension to Install dependencies from Blob (Enabling WinRM)
resource "azurerm_virtual_machine_extension" "win-rm" {
  for_each = azurerm_windows_virtual_machine.example

  name                 = "win-rm-${each.key}"
  virtual_machine_id   = each.value.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    fileUris = [
      "https://eaifdevopsstorage.blob.core.windows.net/eaifdevopsterraform/install.ps1?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2025-01-30T20:26:26Z&st=2025-01-17T12:26:26Z&spr=https,http&sig=JtXbx3q2fl989U2CcuMYT7OEa7anBWC%2Fsa19VG2PmxQ%3D"
    ],
    commandToExecute = <<-EOT
      powershell.exe -ExecutionPolicy Bypass -File install.ps1 
    EOT
  })

  depends_on = [
    azurerm_windows_virtual_machine.example  # Ensure VM is created before running the script
  ]
}

## Null Resource for Provisioners (File and Remote Exec)
#resource "null_resource" "file_remote_exec" {
#  for_each = var.vm_map
#
#  provisioner "file" {
#    source      = "./dir_creation.ps1"  
#    destination = "C:/dir_creation.ps1"  
#
#    connection {
#      host     = azurerm_public_ip.example[each.key].ip_address  # Public IP of the VM
#      type     = "winrm"
#      user     = each.value.admin_username
#      password = each.value.admin_password
#      https    = "false" 
#      insecure = "true"
#      timeout  = "10m"
#    }
#  }
#
#  provisioner "remote-exec" {
#    inline = [
#      # Run the script
#      "powershell.exe -ExecutionPolicy Bypass -File C:/dir_creation.ps1"
#    ]
#
#    connection {
#      host     = azurerm_public_ip.example[each.key].ip_address  # Public IP of the VM
#      type     = "winrm"
#      user     = each.value.admin_username
#      password = each.value.admin_password
#      https    = "false" 
#      insecure = "true"
#      timeout  = "10m" 
#    }
#  }
#}
#