resource "azurerm_sql_failover_group" "sql_failover" {
  name                = "sqlfailoveretl"
  resource_group_name = module.rg_dataint_eu2.name
  server_name         = module.sql_dataint_eu2.name
  databases           = [module.sqldb_dataint_eu2_etl.id]
  partner_servers {
    id = module.sql_dataint_cu1.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}