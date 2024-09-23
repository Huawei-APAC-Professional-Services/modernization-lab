terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.62.0"
    }
  }
}

provider "huaweicloud" {
  region = "ap-southeast-3"
}

provider "huaweicloud" {
  alias = "crm"
  assume_role {
    agency_name = "OrganizationAccountAccessAgency"
    domain_name = "hwstaff_intl_lab_01_app"
  }
  region = "ap-southeast-3"
}