#format

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version=">=1.0"
}
 
provider "azurerm" {
  features {}
}
locals {
 string1       = "str1"
 string2       = "str2"
 int1          = 3
 apply_format  = format("This is %s", local.string1)
 apply_format2 = format("%s_%s_%d", local.string1, local.string2, local.int1)
}

output "apply_format" {
 value = local.apply_format
}
output "apply_format2" {
 value = local.apply_format2
}
