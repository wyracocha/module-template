
module "nsg_shared_05_eu2" {
  source = "../IAAC-MODULES-REPOSITORY/NetworkSecurityGroup/Eu2"

  cod_proyecto        = local.cod_proyecto
  cod_ambiente        = local.cod_ambiente
  correlativo         = local.correlativo
  cod_location        = local.cod_location
  cod_proyecto_arqsop = local.cod_proyecto_arqsop
  resource_group_name = module.rg_shared_01_eu2.name

  log_analytics      = module.log_shared_eu2.id
  monitor_storage_id = azurerm_storage_account.stsharedfuncprod003eu2.id
  #https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet#-common-network-configuration-issues
  custom_rules = [
    {
      name                   = "APIM-AllowClientExternalInbound", priority = "100", direction = "Inbound",
      access                 = "Allow",
      protocol               = "TCP",
      source_port_range      = "*",
      destination_port_range = "443",
      source_address_prefix  = "0.0.0.0/0",
      #destination_address_prefix = "172.17.0.0/22", 10.169.12.0/24
      #destination_address_prefix = "10.169.12.0/24"
      destination_address_prefix = "VirtualNetwork"
    description = "APIM - Client communication to API Management " },
    {
      name                   = "APIM-AllowApiManagementVnet", priority = "101", direction = "Inbound",
      access                 = "Allow",
      protocol               = "TCP",
      source_port_range      = "*",
      destination_port_range = "3443",
      #source_address_prefix = "ApiManagement",
      source_address_prefix = "*",
      #destination_address_prefix = "172.17.0.0/22", 10.169.12.0/24
      #destination_address_prefix = "10.169.12.0/24"
      destination_address_prefix = "VirtualNetwork"
      description                = "APIM - AllowApiManagementVnet"
    },
    {
      name                   = "out", priority = "101", direction = "Outbound",
      access                 = "Allow",
      protocol               = "TCP",
      source_port_range      = "*",
      destination_port_range = "3443",
      source_address_prefix  = "ApiManagement",
      #destination_address_prefix = "172.17.0.0/22", 10.169.12.0/24
      destination_address_prefix = "*"
      description                = "APIM - AllowApiManagementVnet"
    },
    {
      name                   = "out 1886", priority = "102", direction = "Outbound",
      access                 = "Allow",
      protocol               = "TCP",
      source_port_range      = "*"
      destination_port_range = "1886",
      source_address_prefix  = "VirtualNetwork",
      #destination_address_prefix = "172.17.0.0/22", 10.169.12.0/24
      destination_address_prefix = "*"
      description                = "APIM - AllowApiManagementVnet"
    }
  ]
}

## exposition-layer
module "nsg_association_1_eu2" {
  source = "../IAAC-MODULES-REPOSITORY/NSGAssociation"

  #TODO snet
  snet_id = module.snet_shared_03_eu2.id
  nsg_id  = module.nsg_shared_05_eu2.id

  depends_on = [module.snet_shared_03_eu2, module.nsg_shared_05_eu2]
}


### service-layer
module "nsg_shared_06_eu2" {
  source              = "../IAAC-MODULES-REPOSITORY/NetworkSecurityGroup/Eu2"
  cod_proyecto        = local.cod_proyecto
  cod_ambiente        = local.cod_ambiente
  correlativo         = local.correlativo
  cod_location        = local.cod_location
  cod_proyecto_arqsop = local.cod_proyecto_arqsop

  resource_group_name = module.rg_shared_01_eu2.name
  log_analytics       = module.log_shared_eu2.id
  monitor_storage_id  = azurerm_storage_account.stsharedfuncprod003eu2.id
}

#module "nsg_association_2_eu2" {
#  source = "../IAAC-MODULES-REPOSITORY/NSGAssociation"
#
#  snet_id = module.snet_shared_03_eu2.id
#  #snet_id   = module.snet_shared_04_eu2.id
#  nsg_id = module.nsg_shared_06_eu2.id
#
#  depends_on = [module.snet_shared_03_eu2, module.nsg_shared_06_eu2]
#  #depends_on = [module.snet_shared_04_eu2, module.nsg_shared_06_eu2]
#}

module "rg_shared_01_eu2" {
  source = "../IAAC-MODULES-REPOSITORY/ResourceGroup"

  cod_proyecto        = local.cod_proyecto
  cod_ambiente        = local.cod_ambiente
  correlativo         = local.correlativo
  cod_location        = local.cod_location
  cod_proyecto_arqsop = local.cod_proyecto_arqsop

}


