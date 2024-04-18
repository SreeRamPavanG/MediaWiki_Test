resource "azurerm_resource_group" "testtwmediawiki_rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "testtwmediawiki_vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/23"]
  location            = azurerm_resource_group.testtwmediawiki_rg.location
  resource_group_name = azurerm_resource_group.testtwmediawiki_rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal-snet"
  resource_group_name  = azurerm_resource_group.testtwmediawiki_rg.name
  virtual_network_name = azurerm_virtual_network.testtwmediawiki_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_public_ip" "testtwmediawiki_public_ip" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.testtwmediawiki_rg.location
  resource_group_name = azurerm_resource_group.testtwmediawiki_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "testtwmediawiki_nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.testtwmediawiki_rg.location
  resource_group_name = azurerm_resource_group.testtwmediawiki_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "testtwmediawiki_nsg-association" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.testtwmediawiki_nsg.id
}

resource "azurerm_network_interface" "testtwmediawiki_nic" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.testtwmediawiki_rg.name
  location            = azurerm_resource_group.testtwmediawiki_rg.location

  ip_configuration {
    name                          = "external"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testtwmediawiki_public_ip.id
  }
  depends_on = [
    azurerm_public_ip.testtwmediawiki_public_ip
  ]
}

resource "azurerm_key_vault" "testtwmediawiki_kv" {
  name                        = var.keyvault_name
  location                    = azurerm_resource_group.testtwmediawiki_rg.location
  resource_group_name         = azurerm_resource_group.testtwmediawiki_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

# A random string for password
resource "random_password" "randompass" {
  length  = 10
  special = true

}

# Define Azure Key Vault Secret for Windows VM password
resource "azurerm_key_vault_secret" "vmpassword" {
  name         = var.vm_password
  value        = random_password.randompass.result
  key_vault_id = azurerm_key_vault.testtwmediawiki_kv.id
}

# Define Azure Windows Virtual Machine
resource "azurerm_linux_virtual_machine" "testtwmediawiki_vm" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.testtwmediawiki_rg.name
  location            = azurerm_resource_group.testtwmediawiki_rg.location
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  network_interface_ids = [
    azurerm_network_interface.testtwmediawiki_nic.id,
  ]

  os_disk {
    storage_account_type = var.storage_account_type
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "redhat-9-3-gen2"
    version   = "9.3.20240409"
  }
}
