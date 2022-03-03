
module "vnet_shared_01_eu2" {
  source = "../IAAC-MODULES-REPOSITORY/VirtualNetwork"

  cod_proyecto        = local.cod_proyecto
  cod_ambiente        = local.cod_ambiente
  correlativo         = local.correlativo
  cod_location        = local.cod_location
  cod_proyecto_arqsop = local.cod_proyecto_arqsop
  resource_group_name = module.rg_shared_01_eu2.name
  address_space       = ["10.169.0.0/20", "10.169.16.0/22"]
}

module "snet_shared_05_eu2" {
  source = "../IAAC-MODULES-REPOSITORY/Subnet"

  cod_proyecto        = local.cod_proyecto
  cod_ambiente        = local.cod_ambiente
  correlativo         = local.correlativo
  cod_location        = local.cod_location
  cod_proyecto_arqsop = local.cod_proyecto_arqsop

  resource_group_name = module.rg_shared_01_eu2.name
  address_prefix      = ["10.169.8.0/24"]
  virtual_network     = module.vnet_shared_01_eu2.name
  service_endpoints   = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.AzureActiveDirectory", "Microsoft.EventHub"]
}

module "snet_shared_03_eu2" {
  source = "../IAAC-MODULES-REPOSITORY/Subnet"

  cod_proyecto        = local.cod_proyecto
  cod_ambiente        = local.cod_ambiente
  correlativo         = "002"
  cod_location        = local.cod_location
  cod_proyecto_arqsop = local.cod_proyecto_arqsop
  resource_group_name = module.rg_shared_01_eu2.name
  address_prefix      = ["10.169.12.0/24"]
  virtual_network     = module.vnet_shared_01_eu2.name
  service_endpoints   = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.AzureActiveDirectory", "Microsoft.EventHub"]
}

######################################################################
########## ROUTE TABLE
######################################################################

resource "azurerm_route_table" "route_table_eu2" {
  name                          = local.rt_name
  location                      = "East US 2"
  resource_group_name           = module.rg_shared_01_eu2.name
  disable_bgp_route_propagation = true

  route {
    name                   = "hacia-internet-porfweu2"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.169.91.4"
  }
  route {
    name           = "hacia-ControlPlane"
    address_prefix = "20.44.72.3/32"
    next_hop_type  = "Internet"
  }
  route {
    name           = "hacia-SQL1"
    address_prefix = "104.208.150.3/32"
    next_hop_type  = "Internet"
  }
  route {
    name           = "hacia-SQL2"
    address_prefix = "52.167.104.0/32"
    next_hop_type  = "Internet"
  }
  route {
    name           = "haciaGlobal01"
    address_prefix = "104.214.19.224/32"
    next_hop_type  = "Internet"
  }
  route {
    name           = "haciaGlobal02"
    address_prefix = "52.162.110.80/32"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "route_table_assoc_eu2" {
  subnet_id      = module.snet_shared_03_eu2.id
  route_table_id = azurerm_route_table.route_table_eu2.id
}
