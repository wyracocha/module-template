######################################################################
########## NETWORK PROFILE - NECESARIO PARA ACG PRIVADO - DESPLEGAR PRIMERO SNET CON DELEGACION Y LUEGO NETWORK PROFILE
######################################################################


resource "azurerm_network_profile" "netpro_cu1" {
  name                = "netprofile-sftp"
  location            = "Central US"
  resource_group_name = module.rg_dataint_cu1.name

  container_network_interface {
    name = "nic_sftp"

    ip_configuration {
      name      = "ip-cfg-sftp"
      subnet_id = module.snet_dataint_01_cu1.id
      #subnet_id = module.snet_dataint_cu1.id
    }
  }
}


######################################################################
########## CONTAINER REGISTRY - NO ELIMINAR - CONTIENE IMAGEN DE SFTP
######################################################################
module "cr_dataint_cu1" {
  source = "../../IAAC-MODULES-REPOSITORY/ContainerRegistry/Cu1"

  cod_proyecto        = "dataint"
  cod_ambiente        = "prod"
  correlativo         = "001"
  cod_location        = "cu1"
  resource_group_name = module.rg_dataint_cu1.name
  cod_proyecto_arqsop = "arqsop"
  cr_sku              = "Basic"
  cr_admin_enabled    = "true"
  diag_log_id         =  module.log_data_cu1.id
  monitor_storage_id  = module.st_data_cu1.id

  depends_on          = [module.log_data_eu2]
}
######################################################################
########## SFTP IMAGE
######################################################################
resource "null_resource" "sftp_image_cu1" {
  depends_on = [module.cr_dataint_cu1, null_resource.sftp_image_eu2]
  triggers = {
    buildnumber = timestamp()
  }
  provisioner "local-exec" {
    command = "make all"
    environment = {
      DOCKER_REMOTE_HOST = module.cr_dataint_cu1.login_server
      DOCKER_USER = module.cr_dataint_cu1.admin_username
      DOCKER_PWD = module.cr_dataint_cu1.admin_password
      IMAGE_VERSION = "2.3"
    }
  }
}
#
######################################################################
########## CONTAINER GROUP
######################################################################

resource "azurerm_container_group" "sftp_cu1" {
  depends_on          = [null_resource.sftp_image_cu1]
  name                = "ci-dataint-prod-001-cu1-arqsop"
  location            = "Central US"
  resource_group_name = module.rg_dataint_cu1.name
  ip_address_type     = "Private"
  os_type             = "Linux"

  network_profile_id  = azurerm_network_profile.netpro_cu1.id

  image_registry_credential {
    username  = module.cr_dataint_cu1.admin_username
    password  = module.cr_dataint_cu1.admin_password
    server    = module.cr_dataint_cu1.login_server
  }
/*
  image_registry_credential {
    username  = "crdataintqa001cu1arqsop"
    password  = "JJ6jJmnyFAIdAD+vRrrrXuFEWGDzjElw"
    server    = "crdataintqa001cu1arqsop.azurecr.io"
  }
*/
  container {
    name   = "sftp"
    image  = "${module.cr_dataint_cu1.login_server}/sftp-imagen:2.3"
    cpu    = "2"
    memory = "4"


/*
    volume {
      name                  = "fsoracle"
      mount_path            = "/home/ext-oracleerp-global/fs"
      read_only             = false
      share_name            = azurerm_storage_share.fs_oracle_erp_cu1.name
      storage_account_name  = module.st_data_cu1.name
      storage_account_key   = module.st_data_cu1.primary_access_key
    }

    volume {
      name                  = "fssapetl"
      mount_path            = "/home/int-sapetl-interno-col/fs"
      read_only             = false
      share_name            = azurerm_storage_share.fs_sap_etl_cu1.name
      storage_account_name  = module.st_data_cu1.name
      storage_account_key   = module.st_data_cu1.primary_access_key
    }
*/

    volume {
      name                  = "fsoracle"
      mount_path            = "/home/ext-oracleerp-global/fs"
      read_only             = false
      share_name            = "fs-ext-oracle-erp-global-001"
      storage_account_name  = module.st_data_cu1.name
      storage_account_key   = module.st_data_cu1.primary_access_key
    }

    volume {
      name                  = "fssapetl-col"
      mount_path            = "/home/int-sapetl-interno-col/fs"
      read_only             = false
      share_name            = "fs-int-etlcolombia-co-001"
      storage_account_name  = module.st_data_cu1.name
      storage_account_key   = module.st_data_cu1.primary_access_key
    }
/*
    volume {
      name                  = "fssapetl-pe"
      mount_path            = "/home/int-sapetl-interno-pe/fs"
      read_only             = false
      share_name            = "fs-int-etlperu-pe-001"
      storage_account_name  = module.st_data_cu1.name
      storage_account_key   = module.st_data_cu1.primary_access_key
    }

    volume {
      name                  = "fssapetl-cl"
      mount_path            = "/home/int-sapetl-interno-cl/fs"
      read_only             = false
      share_name            = "fs-int-etlchile-cl-001"
      storage_account_name  = module.st_data_cu1.name
      storage_account_key   = module.st_data_cu1.primary_access_key
    }

    volume {
      name                  = "fssapetl-pan"
      mount_path            = "/home/int-sapetl-interno-pan/fs"
      read_only             = false
      share_name            = "fs-int-etlpanama-pa-001"
      storage_account_name  = module.st_data_cu1.name
      storage_account_key   = module.st_data_cu1.primary_access_key
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
resource "azurerm_storage_share" "fs_oracle_erp_cu1" {
  name = "fs-ext-oracle-erp-global-001"

  storage_account_name = module.st_data_cu1.name
  quota = 50
}

resource "azurerm_storage_share" "fs_sap_etl_cu1" {
  name = "fs-int-etlcolombia-co-001"

  storage_account_name = module.st_data_cu1.name
  quota = 50
}
*/

resource "azurerm_storage_share" "fs_oracle_erp_cu1" {
  name = "fs-ext-oracle-erp-global-001"

  storage_account_name = module.st_data_cu1.name
  quota = 50
}

resource "azurerm_storage_share" "fs_sap_etl_cu1" {
  name = "fs-int-etlcolombia-co-001"

  storage_account_name = module.st_data_cu1.name
  quota = 50
}
/*
resource "azurerm_storage_share" "fs_sap_etl_pe_cu1" {
  name = "fs-int-etlperu-pe-001"

  storage_account_name = module.st_data_cu1.name
  quota = 50
}

resource "azurerm_storage_share" "fs_sap_etl_cl_cu1" {
  name = "fs-int-etlchile-cl-001"

  storage_account_name = module.st_data_cu1.name
  quota = 50
}

resource "azurerm_storage_share" "fs_sap_etl_pan_cu1" {
  name = "fs-int-etlpanama-pa-001"

  storage_account_name = module.st_data_cu1.name
  quota = 50
}
*/
######################################################################
########## DIRECTORIES IN FILE SHARES
######################################################################
##fs-ext-oracle-erp-global-001
resource "azurerm_storage_share_directory" "output_oracle_cu1" {
  name                 = "output"
  share_name           = azurerm_storage_share.fs_oracle_erp_cu1.name
  storage_account_name = module.st_data_cu1.name
}
resource "azurerm_storage_share_directory" "output_oracle_cu1_2" {
  name                 = "output/erp"
  share_name           = azurerm_storage_share.fs_oracle_erp_cu1.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.output_oracle_cu1]
}
resource "azurerm_storage_share_directory" "output_oracle_cu1_3" {
  name                 = "output/erp/asientoscontables"
  share_name           = azurerm_storage_share.fs_oracle_erp_cu1.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.output_oracle_cu1_2]
}
resource "azurerm_storage_share_directory" "output_oracle_cu1_3_1" {
  name                 = "output/erp/facturas"
  share_name           = azurerm_storage_share.fs_oracle_erp_cu1.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.output_oracle_cu1_2]
}
resource "azurerm_storage_share_directory" "output_oracle_cu1_4" {
  name                 = "output/erp/asientoscontables/co"
  share_name           = azurerm_storage_share.fs_oracle_erp_cu1.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.output_oracle_cu1_3]
}
resource "azurerm_storage_share_directory" "output_oracle_cu1_4_1" {
  name                 = "output/erp/facturas/co"
  share_name           = azurerm_storage_share.fs_oracle_erp_cu1.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.output_oracle_cu1_3]
}

resource "azurerm_storage_share_directory" "input_oracle_cu1" {
  name                 = "input"
  share_name           = azurerm_storage_share.fs_oracle_erp_cu1.name
  storage_account_name = module.st_data_cu1.name
}
resource "azurerm_storage_share_directory" "input_oracle_cu1_2" {
  name                 = "input/notificacionesRegionales"
  share_name           = azurerm_storage_share.fs_oracle_erp_cu1.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.input_oracle_cu1]
}

resource "azurerm_storage_share_directory" "notificaciones_oracle_cu1" {
  name                 = "notificaciones"
  share_name           = azurerm_storage_share.fs_oracle_erp_cu1.name
  storage_account_name = module.st_data_cu1.name
}
resource "azurerm_storage_share_directory" "notificaciones_oracle_cu1_2_1" {
  name                 = "notificaciones/input"
  share_name           = azurerm_storage_share.fs_oracle_erp_cu1.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.notificaciones_oracle_cu1]
}
resource "azurerm_storage_share_directory" "notificaciones_oracle_cu1_2_2" {
  name                 = "notificaciones/output"
  share_name           = azurerm_storage_share.fs_oracle_erp_cu1.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.notificaciones_oracle_cu1]
}

###fs-int-etlcolombia-co-001
resource "azurerm_storage_share_directory" "error_sap_cu1" {
  name                 = "error"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
}
resource "azurerm_storage_share_directory" "error_sap_cu1_2" {
  name                 = "error/input"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.error_sap_cu1]
}
resource "azurerm_storage_share_directory" "error_sap_cu1_3" {
  name                 = "error/input/erp"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.error_sap_cu1_2]
}
resource "azurerm_storage_share_directory" "error_sap_cu1_4_1" {
  name                 = "error/input/erp/asientoscontables"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.error_sap_cu1_3]
}
resource "azurerm_storage_share_directory" "error_sap_cu1_4_2" {
  name                 = "error/input/erp/facturas"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.error_sap_cu1_3]
}
resource "azurerm_storage_share_directory" "error_sap_cu1_5" {
  name                 = "error/input/erp/asientoscontables/co"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.error_sap_cu1_4_1]
}
resource "azurerm_storage_share_directory" "error_sap_cu1_6" {
  name                 = "error/input/erp/facturas/co"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.error_sap_cu1_4_2]
}

resource "azurerm_storage_share_directory" "input_sap_cu1" {
  name                 = "input"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
}
resource "azurerm_storage_share_directory" "input_sap_cu1_2" {
  name                 = "input/erp"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.input_sap_cu1]
}
resource "azurerm_storage_share_directory" "input_sap_cu1_3_1" {
  name                 = "input/erp/asientoscontables"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.input_sap_cu1_2]
}
resource "azurerm_storage_share_directory" "input_sap_cu1_3_2" {
  name                 = "input/erp/facturas"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.input_sap_cu1_2]
}
resource "azurerm_storage_share_directory" "input_sap_cu1_4" {
  name                 = "input/erp/asientoscontables/co"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.input_sap_cu1_3_1]
}
resource "azurerm_storage_share_directory" "input_sap_cu1_5" {
  name                 = "input/erp/facturas/co"
  share_name           = azurerm_storage_share.fs_sap_etl.name
  storage_account_name = module.st_data_cu1.name
  depends_on = [azurerm_storage_share_directory.input_sap_cu1_3_2]
}


######################################################################
########## CONTAINERS STORAGE ACCOUNT
######################################################################
resource "azurerm_storage_container" "etlcolombia-decrypt-facturas_cu1" {
  name                  = "co-etlcolombia-erp-input-decrypt-facturas"
  storage_account_name  = module.st_data_cu1.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "etlcolombia-decrypt-asientoscontables_cu1" {
  name                  = "co-etlcolombia-erp-input-decrypt-asientoscontables"
  storage_account_name  = module.st_data_cu1.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "etlcolombia-input-asientos_cu1" {
  name                  = "co-etlcolombia-erp-input-asientoscontables"
  storage_account_name  = module.st_data_cu1.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "etlcolombia-input-facturas_cu1" {
  name                  = "co-etlcolombia-erp-input-facturas"
  storage_account_name  = module.st_data_cu1.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "etlcolombia-output-asientos_cu1" {
  name                  = "co-etlcolombia-erp-output-asientoscontables"
  storage_account_name  = module.st_data_cu1.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "etlcolombia-output-facturas_cu1" {
  name                  = "co-etlcolombia-erp-output-facturas"
  storage_account_name  = module.st_data_cu1.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "errors_cu1" {
  name                  = "general-errors"
  storage_account_name  = module.st_data_cu1.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "output-files_cu1" {
  name                  = "general-output-files"
  storage_account_name  = module.st_data_cu1.name
  container_access_type = "private"
}
