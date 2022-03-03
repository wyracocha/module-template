######################################################################
########## RESOURCE GROUPS
######################################################################
module "rg_dataint_cu1" {
  source = "../../IAAC-MODULES-REPOSITORY/ResourceGroup"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  correlativo         = "001"
  cod_location        = "cu1"
  cod_proyecto_arqsop = "arqsop"
}

######################################################################
######### VIRTUAL NETWORKS
######################################################################
/*
module "vnet_dataint_cu1" {
  source = "../../IAAC-MODULES-REPOSITORY/VirtualNetwork"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  correlativo         = "002"
  cod_location        = "cu1"
  resource_group_name = module.rg_dataint_cu1.name
  address_space       = ["172.20.16.0/22"]
  cod_proyecto_arqsop = "arqsop"
}
*/

module "vnet_dataint_01_cu1" {
  source = "../../IAAC-MODULES-REPOSITORY/VirtualNetwork"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  correlativo         = "001"
  cod_location        = "cu1"
  resource_group_name = module.rg_dataint_cu1.name
  address_space       = ["10.170.40.0/21","10.170.48.0/23"]
  cod_proyecto_arqsop = "arqsop"
}

######################################################################
########## SUBNET
######################################################################
/*
module "snet_dataint_cu1" {
  source = "../../IAAC-MODULES-REPOSITORY/Subnet"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  correlativo         = "003"
  cod_location        = "cu1"
  resource_group_name = module.rg_dataint_cu1.name
  address_prefix      = ["172.20.16.0/24"]
  cod_proyecto_arqsop = "arqsop"
  virtual_network     = module.vnet_dataint_cu1.name
  service_endpoints   = ["Microsoft.KeyVault", "Microsoft.Storage"]
  enf_priv_endp       = "true"
  delegation_conditional  = "true"
  delegation_name         = "snet_delegation"
  delegation_svce_name    = "Microsoft.ContainerInstance/containerGroups"
  delegation_acts_name    = ["Microsoft.Network/virtualNetworks/subnets/action"]

  depends_on          = [module.vnet_dataint_cu1]
}
*/

module "snet_dataint_01_cu1" {
  source = "../../IAAC-MODULES-REPOSITORY/Subnet"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  correlativo         = "001"
  cod_location        = "cu1"
  resource_group_name = module.rg_dataint_cu1.name
  address_prefix      = ["10.170.40.0/21"]
  cod_proyecto_arqsop = "arqsop"
  virtual_network     = module.vnet_dataint_01_cu1.name
  service_endpoints   = ["Microsoft.KeyVault", "Microsoft.Storage"]
  enf_priv_endp       = "true"
  delegation_conditional  = "true"
  delegation_name         = "snet_delegation"
  delegation_svce_name    = "Microsoft.ContainerInstance/containerGroups"
  delegation_acts_name    = ["Microsoft.Network/virtualNetworks/subnets/action"]

  depends_on          = [module.vnet_dataint_01_cu1]
}

######################################################################
########## NETWORK SECURITY GROUP
######################################################################
/*
module "nsg_dataint_cu1" {
  source = "../../IAAC-MODULES-REPOSITORY/NetworkSecurityGroup/Cu1"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  correlativo         = "004"
  cod_location        = "cu1"
  resource_group_name = module.rg_dataint_cu1.name
  cod_proyecto_arqsop = "arqsop"
  log_analytics       = module.log_data_cu1.id

  depends_on          = [module.log_data_cu1]
}
*/
# ####COMENTAR ESTO
#   # custom_rules = [{ name = "AllowExternalInbound", priority = "101", direction = "Inbound",
#   #   access = "Allow",
#   #   protocol = "*",
#   #   source_port_range = "*",
#   #   destination_port_range = "*",
#   #   source_address_prefix = "10.0.0.0/16",
#   #   destination_address_prefix = "*",
#   #   description = "Regla para permitir el acceso desde la red Externa" },
#   #   { name = "AllowOnpremiseInbound", priority = "102", direction = "Inbound",
#   #   access = "Allow",
#   #   protocol = "*",
#   #   source_port_range = "*",
#   #   destination_port_range = "*",
#   #   source_address_prefix = "10.0.0.0/16",
#   #   destination_address_prefix = "*",
#   #   description = "Regla para permitir el acceso desde las redes on-premise" },
#   #   { name = "AllowOnpremiseInbound", priority = "103", direction = "Outbound",
#   #   access = "Allow",
#   #   protocol = "*",
#   #   source_port_range = "*",
#   #   destination_port_range = "*",
#   #   source_address_prefix = "*",
#   #   destination_address_prefix = "10.1.0.0/16",
#   #   description = "Regla para acceder a los recursos on-premise" }]

######################################################################
########## KEY VAULT
######################################################################
module "kv_dataint_cu1" {
  source = "../../IAAC-MODULES-REPOSITORY/KeyVault/Cu1"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prd"
  correlativo         = "005"
  cod_location        = "cu1"
  resource_group_name = module.rg_dataint_cu1.name
  sku_name            = "standard"
  cod_proyecto_arqsop = "arqsop"
  virtual_network_subnet_ids = [module.snet_dataint_01_cu1.id]
  #virtual_network_subnet_ids = [module.snet_dataint_cu1.id]
  log_analytics       = module.log_data_cu1.id
  monitor_storage_id  = module.st_data_cu1.id

  depends_on          = [module.log_data_cu1, module.snet_dataint_01_cu1]
  #depends_on          = [module.log_data_cu1, module.snet_dataint_cu1]
}

######################################################################
########## DATA FACTORY
######################################################################
module "adf_dataint_cu1" {
  source              = "../../IAAC-MODULES-REPOSITORY/DataFactory/Cu1"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  correlativo         = "007"
  cod_location        = "cu1"
  resource_group_name = module.rg_dataint_cu1.name
  cod_proyecto_arqsop = "arqsop"
  log_analytics       = module.log_data_cu1.id
  monitor_storage_id  = module.st_data_cu1.id

  depends_on          = [module.log_data_cu1]
}

######################################################################
########## STORAGE ACCOUNT
######################################################################
module "st_data_cu1" {
  source              = "../../IAAC-MODULES-REPOSITORY/StorageAccount/Cu1"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  correlativo         = "008"
  cod_location        = "cu1"
  resource_group_name = module.rg_dataint_cu1.name
  cod_proyecto_arqsop = "arqsop"
  account_tier        = "standard"
  access_tier         = "Hot"
  replication_type    = "LRS"
  log_analytics       = module.log_data_cu1.id
  monitor_storage_id  = module.st_data_cu1.id

  depends_on = [module.log_data_cu1]
}

######################################################################
########## LOG ANALYTICS WORKSPACE
######################################################################
module "log_data_cu1" {
  source = "../../IAAC-MODULES-REPOSITORY/LogAnalyticsWorkspace"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  correlativo         = "009"
  cod_location        = "cu1"
  resource_group_name = module.rg_dataint_cu1.name
  cod_proyecto_arqsop = "arqsop"
  sku                 = "PerGB2018"
}

######################################################################
########## SQL SERVER
######################################################################
module "sql_dataint_cu1" {
  source              = "../../IAAC-MODULES-REPOSITORY/SQLServer"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  cod_location        = "cu1"
  correlativo         = "202"
  cod_proyecto_arqsop = "arqsop"
  resource_group_name = module.rg_dataint_cu1.name
  sql_version         = "12.0"
}

######################################################################
########## NSG ASSOCIATION
######################################################################
/*
module "nsg_association_cu1" {
  source = "../../IAAC-MODULES-REPOSITORY/NSGAssociation"

  snet_id   = module.snet_dataint_01_cu1.id
  #snet_id   = module.snet_dataint_cu1.id
  nsg_id    = module.nsg_dataint_cu1.id

  depends_on = [module.snet_dataint_01_cu1, module.nsg_dataint_cu1]
  #depends_on = [module.snet_dataint_cu1, module.nsg_dataint_cu1]
}
*/

######################################################################
########## ROUTE TABLE
######################################################################
resource "azurerm_route_table" "route_table_cu1" {
  name                          = "route-dataint-prod-001-cu1-arqsop"
  location                      = "Central US"
  resource_group_name           = module.rg_dataint_cu1.name
  disable_bgp_route_propagation = true

  route {
    name                    = "hacia-internet-porfwcu1"
    address_prefix          = "0.0.0.0/0"
    next_hop_type           = "VirtualAppliance"
    next_hop_in_ip_address  = "10.170.91.4"
  }

  #tags = {
  #  environment = "Production"
  #}
}

resource "azurerm_subnet_route_table_association" "route_table_assoc_cu1" {
  subnet_id      = module.snet_dataint_01_cu1.id
  #subnet_id      = module.snet_dataint_cu1.id
  route_table_id = azurerm_route_table.route_table_cu1.id
}


######################################################################
########## FUNCTION APP
######################################################################
/*
resource "azurerm_storage_account" "fnapcu1prodstorage" {
  name                     = "fnapcu1prodstorage"
  resource_group_name      = module.rg_dataint_cu1.name
  location                 = "centralus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "database_failover_function_app_cu1" {
  source = "../../IAAC-MODULES-REPOSITORY/FunctionApp"

  cod_proyecto               = "dataint"
  cod_ambiente               = "prod"
  correlativo                = "019"
  cod_location               = "cu1"
  resource_group_name        = module.rg_dataint_cu1.name
  cod_proyecto_arqsop        = "arqsop"
  fnap_storage_account_name  = azurerm_storage_account.fnapcu1prodstorage.name
  fnap_storage_account_access_key = azurerm_storage_account.fnapcu1prodstorage.primary_access_key

  depends_on = [azurerm_storage_account.fnapcu1prodstorage]
}

resource "azurerm_role_assignment" "cu1_fnap_owner_over_eu2_sql" {
  scope                = module.sql_dataint_eu2.id
  role_definition_name = "Owner"
  principal_id         = module.database_failover_function_app_cu1.identity_id
}

resource "azurerm_role_assignment" "cu1_fnap_owner_over_cu1_sql" {
  scope                = module.sql_dataint_cu1.id
  role_definition_name = "Owner"
  principal_id         = module.database_failover_function_app_cu1.identity_id
}
*/
