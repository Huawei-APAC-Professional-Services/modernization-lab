resource "huaweicloud_vpc_eip" "nginx" {
  provider = huaweicloud.crm
  publicip {
    type = "5_bgp"
  }

  bandwidth {
    share_type  = "PER"
    name        = "onprem-dmz"
    size        = 300
    charge_mode = "traffic"
  }
}

module "nginx_security_group" {
  providers = {
    huaweicloud = huaweicloud.crm
  }
  source             = "github.com/Huawei-APAC-Professional-Services/terraform-module/securitygroup"
  securitygroup_name = "dmz-nginx"
  rules = [{
    name     = "http"
    ports    = "80"
    priority = 1
  }]
}

module "nginx_proxy" {
  providers = {
    huaweicloud = huaweicloud.crm
  }
  source           = "github.com/Huawei-APAC-Professional-Services/terraform-module/ecs"
  ecs_name         = "onprem-dmz-nginx"
  image_name       = "Ubuntu 22.04 server 64bit"
  image_visibility = "public"
  flavor_id        = "c7n.large.2"
  secgroup_ids     = [module.nginx_security_group.security_group_id]
  system_disk_type = "SSD"
  system_disk_size = 50
  networks = [
    {
      subnet_id = module.network_onprem.subnets["onprem-dmz"]
    }
  ]
  eip_id                      = huaweicloud_vpc_eip.nginx.id
  delete_eip_on_termination   = true
  delete_disks_on_termination = true
  admin_pass                  = "Pass@w0rd@bootHW"
  user_data                   = templatefile("nginx_proxy.yaml", { nginxConfig = base64encode(templatefile("nginx_proxy.conf", { wordpress_server = module.wordpress.ecs_private_ipv4_address })) })
  availability_zone           = "ap-southeast-3a"
  depends_on                  = [module.network_onprem, huaweicloud_nat_snat_rule.prod]
}