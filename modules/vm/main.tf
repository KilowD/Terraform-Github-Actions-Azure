

# create VM
resource "azurerm_virtual_network" "dollar_virtual_network" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location 
  resource_group_name = var.base_name 
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-internal_netwotk"
  resource_group_name  = var.location 
  virtual_network_name = azurerm_virtual_network.dollar_virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "dollar_nic" {
  name                = "${var.prefix}-nic"
  location            = var.location 
  resource_group_name = var.base_name 

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "dollar_virtual_machine" {
  name                  = "${var.prefix}-vm"
  location              = var.location 
  resource_group_name   = var.base_name 
  network_interface_ids = [azurerm_network_interface.dollar_nic.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}