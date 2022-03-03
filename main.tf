locals {
  ok = "ok"
}
resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "/@£$"
}
output {
  value = local.ok
}
