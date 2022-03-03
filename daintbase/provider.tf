# Configure the Azure backend
#terraform {
#  backend "azurerm" {
#    resource_group_name   = "RG-DATAINT-PROD-100-EU2-ARQSOP"
#    storage_account_name  = "stdataintprod100eu2"
#    #el container varia dependiendo la capa
#    container_name        = "data-integration-prod"
#    key                   = "terraform_base.tfstate"
#  }
#}

# Configure the Azure provider
#provider "azurerm" {
#  version = "~>2.0"
#  features {}
#}
provider "azurerm" {
  version = "~>2.0"
  features {}

  ##TODO DELETE THIS
  subscription_id = "d32248ab-7cca-4946-9991-f94c7ba40ebd"
}
