/*
# tf state backend
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tools-dev-weu"
    storage_account_name = "backendtfstatedevweu01"
    container_name       = "backend-tfstate-dev-weu-01"
    key                  = "aks/test/weu/tf.tfstate"
  }
}
*/
