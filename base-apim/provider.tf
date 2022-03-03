
terraform {
  backend "azurerm" {
    #resource_group_name   = "RG-SHAREDSVC-PROD-100-EU2-ARQSOP"
    #storage_account_name  = "stsharedsvcprod100eu2"
    #el container varia dependiendo la capa
    #container_name        = "shared-services-dev"
    key                   = "terraform-dev-test-wvg.tfstate"
  }
}

locals {
  cod_proyecto        = "sharedt"
  cod_ambiente        = "dev"
  correlativo         = "509"
  cod_location        = "eu2"
  cod_proyecto_arqsop = "arqsopt"

  stac_name = "stac${local.cod_proyecto}${local.cod_ambiente}${local.correlativo}${local.cod_location}"
  rt_name   = "rt${local.cod_proyecto}${local.cod_ambiente}${local.correlativo}${local.cod_location}"
}

provider "azurerm" {
  features {}
  #subscription_id = "d32248ab-7cca-4946-9991-f94c7ba40ebd"
}


resource "azurerm_storage_account" "stsharedfuncprod003eu2" {
  name                     = local.stac_name
  resource_group_name      = module.rg_shared_01_eu2.name
  location                 = "eastus2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


module "log_shared_eu2" {
  source = "../IAAC-MODULES-REPOSITORY/LogAnalyticsWorkspace"

  cod_proyecto        = local.cod_proyecto
  cod_ambiente        = local.cod_ambiente
  correlativo         = local.correlativo
  cod_location        = local.cod_location
  cod_proyecto_arqsop = local.cod_proyecto_arqsop
  resource_group_name = module.rg_shared_01_eu2.name

}



