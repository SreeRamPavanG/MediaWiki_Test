terraform {
  backend "azurerm" {
    storage_account_name = ""
    container_name       = "tfstatefiles"
    key                  = "mediawikiterraform.tfstate"
  }
}


resource "azurerm_storage_account" "teststate_storage" {
  name                     = var.storage_name
  resource_group_name      = azurerm_resource_group.testtwmediawiki_rg.name
  location                 = azurerm_resource_group.testtwmediawiki_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}
