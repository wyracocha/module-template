
module "apim_shared_06_eu2" {
  count  = 0
  source = "../IAAC-MODULES-REPOSITORY/ApiManagement/Eu2"

  cod_proyecto        = local.cod_proyecto
  cod_ambiente        = local.cod_ambiente
  correlativo         = local.correlativo
  cod_location        = local.cod_location
  cod_proyecto_arqsop = local.cod_proyecto_arqsop
  resource_group_name = module.rg_shared_01_eu2.name

  apim_sku             = "Premium"
  apim_deployed_units  = "1"
  apim_publisher_name  = "Credicorp_Capital"
  apim_publisher_email = "pedrotapia@credicorpcapital.com"
  apim_diag_log_id     = module.log_shared_eu2.id
  apim_vnet_type       = "Internal"
  apim_snet_id         = module.snet_shared_03_eu2.id

  apim_additional_vn = "true"
  apim_snet_add1_id  = ""
  #additional_location     = [{ location = "Central US" }]

  apim_policy = <<XML
                              <policies>
                                  <inbound>
                                  </inbound>
                                  <backend>
                                      <forward-request />
                                  </backend>
                                  <outbound />
                                  <on-error />
                              </policies>
                              XML

  apim_oauth2                     = "0"
  apim_oauth2_name                = "oauth2-adb2c"
  apim_oauth2_client_registration = "http://localhost"
  apim_oauth2_grant_types         = ["clientCredentials"]
  apim_oauth2_au_endpoint         = "https://login.microsoftonline.com/964597e6-ba67-497b-ac14-96bdb5dd48b7/oauth2/v2.0/authorize"
  apim_oauth2_rq_method           = ["GET"]
  apim_oauth2_token_endpoint      = "https://login.microsoftonline.com/964597e6-ba67-497b-ac14-96bdb5dd48b7/oauth2/v2.0/token"
  apim_oauth2_client_au_method    = ["Body"]
  apim_oauth2_default_scope       = "https://credicorpcapitalglobal.onmicrosoft.com/8f8fe7b1-dc3c-48ae-92b2-2e5a3c88f954/.default"
  apim_oauth2_client_id           = "586837c4-d38d-4b24-8b74-51ac24220b1a "
  apim_oauth2_client_secret       = "1_xS-Wq_F281Kx_D4plqz3eSk1-k-LCs4y"
  apim_oauth2_token_method        = ["authorizationHeader"]

  apim_oauth2_2                    = "0"
  apim_oauth2_name2                = "oauth2-adb2c-notification"
  apim_oauth2_client_registration2 = "http://localhost"
  apim_oauth2_grant_types2         = ["clientCredentials"]
  apim_oauth2_au_endpoint2         = "https://login.microsoftonline.com/964597e6-ba67-497b-ac14-96bdb5dd48b7/oauth2/v2.0/authorize"
  apim_oauth2_rq_method2           = ["GET"]
  apim_oauth2_token_endpoint2      = "https://login.microsoftonline.com/964597e6-ba67-497b-ac14-96bdb5dd48b7/oauth2/v2.0/token"
  apim_oauth2_client_au_method2    = ["Body"]
  apim_oauth2_default_scope2       = "https://credicorpcapitalglobal.onmicrosoft.com/8f8fe7b1-dc3c-48ae-92b2-2e5a3c88f954/.default"
  apim_oauth2_client_id2           = "5a514fab-e0f9-4a9d-a71f-e1b4c1fa2bef"
  apim_oauth2_client_secret2       = "EcW6exkhmdbYn2u36P~1be7APu.F0s-.jr"
  apim_oauth2_token_method2        = ["authorizationHeader"]


  monitor_storage_id = azurerm_storage_account.stsharedfuncprod003eu2.id
}

#az rest --method delete --url https://management.azure.com/subscriptions/d32248ab-7cca-4946-9991-f94c7ba40ebd/providers/Microsoft.ApiManagement/locations/eastus2/deletedservices/apim-sharedt-dev-509-eu2-arqsopt\?api-version\=2020-06-01-preview
#az rest --method GET --url https://management.azure.com/subscriptions/d32248ab-7cca-4946-9991-f94c7ba40ebd/providers/Microsoft.ApiManagement/deletedservices\?api-version\=2020-06-01-preview
