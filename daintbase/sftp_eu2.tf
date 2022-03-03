######################################################################
########## NETWORK PROFILE - NECESARIO PARA ACG PRIVADO - DESPLEGAR PRIMERO SNET CON DELEGACION Y LUEGO NETWORK PROFILE
######################################################################

resource "azurerm_network_profile" "netpro" {
  name                = "netprofile-sftp"
  location            = "East Us 2"
  resource_group_name = module.rg_dataint_eu2.name

  container_network_interface {
    name = "nic_sftp"

    ip_configuration {
      name      = "ip-cfg-sftp"
      subnet_id = module.snet_dataint_01_eu2.id
      #subnet_id = module.snet_dataint_eu2.id
    }
  }
}

######################################################################
########## CONTAINER REGISTRY - NO ELIMINAR - CONTIENE IMAGEN DE SFTP
######################################################################
module "cr_dataint_eu2" {
  source = "../../IAAC-MODULES-REPOSITORY/ContainerRegistry/Eu2"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  correlativo         = "001"
  cod_location        = "eu2"
  resource_group_name = module.rg_dataint_eu2.name
  cod_proyecto_arqsop = "arqsop"
  cr_sku              = "Basic"
  cr_admin_enabled    = "true"
  diag_log_id         =  module.log_data_eu2.id
  monitor_storage_id    = module.st_data_eu2.id

  depends_on          = [module.log_data_eu2]
}
######################################################################
########## SFTP IMAGE
######################################################################
resource "null_resource" "sftp_image_eu2" {
  depends_on          = [module.cr_dataint_eu2]
  triggers = {
    before = module.cr_dataint_eu2.login_server
  }
  provisioner "local-exec" {
    command = "make all"
    environment = {
      DOCKER_REMOTE_HOST = module.cr_dataint_eu2.login_server
      DOCKER_USER = module.cr_dataint_eu2.admin_username
      DOCKER_PWD = module.cr_dataint_eu2.admin_password
      IMAGE_VERSION = "2.3"
    }
  }
}
######################################################################
########## CONTAINER GROUP
######################################################################

resource "azurerm_container_group" "sftp" {
  depends_on          = [null_resource.sftp_image_eu2]
  name                = "ci-dataint-prod-001-eu2-arqsop"
  location            = "East US 2"
  resource_group_name = module.rg_dataint_eu2.name
  ip_address_type     = "Private"
  os_type             = "Linux"

  network_profile_id  = azurerm_network_profile.netpro.id

  image_registry_credential {
    username  = module.cr_dataint_eu2.admin_username
    password  = module.cr_dataint_eu2.admin_password
    server    = module.cr_dataint_eu2.login_server
  }

  container {
    name   = "sftp"
    image  = "${module.cr_dataint_eu2.login_server}/sftp-imagen:2.3"
    cpu    = "2"
    memory = "4"

/*
    volume {
      name                  = "fsoracle"
      mount_path            = "/home/ext-oracleerp-global/fs"
      read_only             = false
      share_name            = azurerm_storage_share.fs_oracle_erp.name
      storage_account_name  = module.st_data_eu2.name
      storage_account_key   = module.st_data_eu2.primary_access_key
    }

    volume {
      name                  = "fssapetl"
      mount_path            = "/home/int-sapetl-interno-col/fs"
      read_only             = false
      share_name            = azurerm_storage_share.fs_sap_etl.name
      storage_account_name  = module.st_data_eu2.name
      storage_account_key   = module.st_data_eu2.primary_access_key
    }
*/
    volume {
      name                  = "fsoracle"
      mount_path            = "/home/ext-oracleerp-global/fs"
      read_only             = false
      share_name            = "fs-ext-oracle-erp-global-001"
      storage_account_name  = module.st_data_eu2.name
      storage_account_key   = module.st_data_eu2.primary_access_key
    }

    volume {
      name                  = "fssapetl-col"
      mount_path            = "/home/int-sapetl-interno-col/fs"
      read_only             = false
      share_name            = "fs-int-etlcolombia-co-001"
      storage_account_name  = module.st_data_eu2.name
      storage_account_key   = module.st_data_eu2.primary_access_key
    }
/*
    volume {
      name                  = "fssapetl-pe"
      mount_path            = "/home/int-sapetl-interno-pe/fs"
      read_only             = false
      share_name            = "fs-int-etlperu-pe-001"
      storage_account_name  = module.st_data_eu2.name
      storage_account_key   = module.st_data_eu2.primary_access_key
    }

    volume {
      name                  = "fssapetl-cl"
      mount_path            = "/home/int-sapetl-interno-cl/fs"
      read_only             = false
      share_name            = "fs-int-etlchile-cl-001"
      storage_account_name  = module.st_data_eu2.name
      storage_account_key   = module.st_data_eu2.primary_access_key
    }

    volume {
      name                  = "fssapetl-pan"
      mount_path            = "/home/int-sapetl-interno-pan/fs"
      read_only             = false
      share_name            = "fs-int-etlpanama-pa-001"
      storage_account_name  = module.st_data_eu2.name
      storage_account_key   = module.st_data_eu2.primary_access_key
    }
*/

    ports {
      port     = 22
      protocol = "TCP"
    }
  }

  timeouts {
    create = "5m"
    delete = "5m"
  }


  #tags = local.tags
}

######################################################################
########## FILE SHARES
######################################################################
/*
resource "azurerm_storage_share" "fs_oracle_erp" {
  name = "fs-ext-oracle-erp-global-001"

  storage_account_name = module.st_data_eu2.name
  quota = 50
}

resource "azurerm_storage_share" "fs_sap_etl" {
  name = "fs-int-etlcolombia-co-001"

  storage_account_name = module.st_data_eu2.name
  quota = 50

}
*/

resource "azurerm_storage_share" "fs_oracle_erp" {
  name = "fs-ext-oracle-erp-global-001"

  storage_account_name = module.st_data_eu2.name
  quota = 50
}

resource "azurerm_storage_share" "fs_sap_etl" {
  name = "fs-int-etlcolombia-co-001"

  storage_account_name = module.st_data_eu2.name
  quota = 50
}
/*
resource "azurerm_storage_share" "fs_sap_etl_pe" {
  name = "fs-int-etlperu-pe-001"

  storage_account_name = module.st_data_eu2.name
  quota = 50
}

resource "azurerm_storage_share" "fs_sap_etl_cl" {
  name = "fs-int-etlchile-cl-001"

  storage_account_name = module.st_data_eu2.name
  quota = 50
}

resource "azurerm_storage_share" "fs_sap_etl_pan" {
  name = "fs-int-etlpanama-pa-001"

  storage_account_name = module.st_data_eu2.name
  quota = 50
}
*/
######################################################################
########## DIRECTORIES IN FILE SHARES
######################################################################
##fs-ext-oracle-erp-global-001
resource "azurerm_storage_share_directory" "output_oracle" {
  name                 = "output"
  share_name           = azurerm_storage_share.fs_oracle_erp.name
  storage_account_name = module.st_data_eu2.name
}
resource "azurerm_storage_share_directory" "output_oracle_2" {
  name                 = "output/erp"
  share_name           = azurerm_storage_share.fs_oracle_erp.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.output_oracle]
}
resource "azurerm_storage_share_directory" "output_oracle_3" {
  name                 = "output/erp/asientoscontables"
  share_name           = azurerm_storage_share.fs_oracle_erp.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.output_oracle_2]
}
resource "azurerm_storage_share_directory" "output_oracle_3_1" {
  name                 = "output/erp/facturas"
  share_name           = azurerm_storage_share.fs_oracle_erp.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.output_oracle_2]
}
resource "azurerm_storage_share_directory" "output_oracle_4" {
  name                 = "output/erp/asientoscontables/co"
  share_name           = azurerm_storage_share.fs_oracle_erp.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.output_oracle_3]
}
resource "azurerm_storage_share_directory" "output_oracle_4_1" {
  name                 = "output/erp/facturas/co"
  share_name           = azurerm_storage_share.fs_oracle_erp.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.output_oracle_3]
}

resource "azurerm_storage_share_directory" "input_oracle" {
  name                 = "input"
  share_name           = azurerm_storage_share.fs_oracle_erp.name
  storage_account_name = module.st_data_eu2.name
}
resource "azurerm_storage_share_directory" "input_oracle_2" {
  name                 = "input/notificacionesRegionales"
  share_name           = azurerm_storage_share.fs_oracle_erp.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.input_oracle]
}

resource "azurerm_storage_share_directory" "notificaciones_oracle" {
  name                 = "notificaciones"
  share_name           = azurerm_storage_share.fs_oracle_erp.name
  storage_account_name = module.st_data_eu2.name
}
resource "azurerm_storage_share_directory" "notificaciones_oracle_2_1" {
  name                 = "notificaciones/input"
  share_name           = azurerm_storage_share.fs_oracle_erp.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.notificaciones_oracle]
}
resource "azurerm_storage_share_directory" "notificaciones_oracle_2_2" {
  name                 = "notificaciones/output"
  share_name           = azurerm_storage_share.fs_oracle_erp.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.notificaciones_oracle]
}

###fs-int-etlcolombia-co-001
resource "azurerm_storage_share_directory" "error_sap" {
  name                 = "error"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
}
resource "azurerm_storage_share_directory" "error_sap_2" {
  name                 = "error/input"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.error_sap]
}
resource "azurerm_storage_share_directory" "error_sap_3" {
  name                 = "error/input/erp"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.error_sap_2]
}
resource "azurerm_storage_share_directory" "error_sap_4_1" {
  name                 = "error/input/erp/asientoscontables"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.error_sap_3]
}
resource "azurerm_storage_share_directory" "error_sap_4_2" {
  name                 = "error/input/erp/facturas"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.error_sap_3]
}
resource "azurerm_storage_share_directory" "error_sap_5" {
  name                 = "error/input/erp/asientoscontables/co"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.error_sap_4_1]
}
resource "azurerm_storage_share_directory" "error_sap_6" {
  name                 = "error/input/erp/facturas/co"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.error_sap_4_2]
}

resource "azurerm_storage_share_directory" "input_sap" {
  name                 = "input"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
}
resource "azurerm_storage_share_directory" "input_sap_2" {
  name                 = "input/erp"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.input_sap]
}
resource "azurerm_storage_share_directory" "input_sap_3_1" {
  name                 = "input/erp/asientoscontables"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.input_sap_2]
}
resource "azurerm_storage_share_directory" "input_sap_3_2" {
  name                 = "input/erp/facturas"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.input_sap_2]
}
resource "azurerm_storage_share_directory" "input_sap_4" {
  name                 = "input/erp/asientoscontables/co"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.input_sap_3_1]
}
resource "azurerm_storage_share_directory" "input_sap_5" {
  name                 = "input/erp/facturas/co"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_eu2.name
  depends_on = [azurerm_storage_share_directory.input_sap_3_2]
}


######################################################################
########## CONTAINERS STORAGE ACCOUNT
######################################################################
resource "azurerm_storage_container" "etlcolombia-decrypt-facturas" {
  name                  = "co-etlcolombia-erp-input-decrypt-facturas"
  storage_account_name  = module.st_data_eu2.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "etlcolombia-decrypt-asientoscontables" {
  name                  = "co-etlcolombia-erp-input-decrypt-asientoscontables"
  storage_account_name  = module.st_data_eu2.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "etlcolombia-input-asientos" {
  name                  = "co-etlcolombia-erp-input-asientoscontables"
  storage_account_name  = module.st_data_eu2.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "etlcolombia-input-facturas" {
  name                  = "co-etlcolombia-erp-input-facturas"
  storage_account_name  = module.st_data_eu2.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "etlcolombia-output-asientos" {
  name                  = "co-etlcolombia-erp-output-asientoscontables"
  storage_account_name  = module.st_data_eu2.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "etlcolombia-output-facturas" {
  name                  = "co-etlcolombia-erp-output-facturas"
  storage_account_name  = module.st_data_eu2.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "errors" {
  name                  = "general-errors"
  storage_account_name  = module.st_data_eu2.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "output-files" {
  name                  = "general-output-files"
  storage_account_name  = module.st_data_eu2.name
  container_access_type = "private"
}
