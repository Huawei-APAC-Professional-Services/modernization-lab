module "db_security_group" {
  providers = {
    huaweicloud = huaweicloud.crm
  }
  source             = "github.com/Huawei-APAC-Professional-Services/terraform-module/securitygroup"
  securitygroup_name = "mysql"
  rules = [{
    name     = "3306"
    ports    = "3306"
    priority = 1
  }]
}

module "database" {
  providers = {
    huaweicloud = huaweicloud.crm
  }
  source           = "github.com/Huawei-APAC-Professional-Services/terraform-module/ecs"
  ecs_name         = "onprem-mysql"
  image_name       = "Ubuntu 22.04 server 64bit"
  image_visibility = "public"
  flavor_id        = "c7n.large.2"
  secgroup_ids     = [module.db_security_group.security_group_id]
  system_disk_type = "SSD"
  system_disk_size = 50
  networks = [
    {
      subnet_id = module.network_onprem.subnets["onprem-prod"]
    }
  ]
  delete_eip_on_termination   = true
  delete_disks_on_termination = true
  admin_pass                  = "PartnerbootCamp@2024IN"
  user_data                   = file("mysql.yaml")
  availability_zone           = "ap-southeast-3a"
  depends_on                  = [module.network_onprem, huaweicloud_nat_snat_rule.prod]
}