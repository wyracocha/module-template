terraform {
  backend "azurerm" {
    resource_group_name   = "RG-SHARED-DEV-001-EU2-ARQSOP"
    storage_account_name  = "stsharedsvcprod100eu2"
    #el container varia dependiendo la capa
    container_name        = "shared-services-dev"
    key                   = "terraform_test.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "d32248ab-7cca-4946-9991-f94c7ba40ebd"
}
