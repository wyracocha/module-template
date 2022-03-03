locals {
  ok = "ok2"
}
resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "/@£$"
}
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

module "rg_dataint_cu1" {
  source = "../IAAC-MODULES-REPOSITORY/ResourceGroup"

  cod_proyecto        = "dataint"
  cod_ambiente        = "dev"
  correlativo         = "202"
  cod_location        = "cu1"
  cod_proyecto_arqsop = "arqsop"
}
output ok {
  value = local.ok
}
