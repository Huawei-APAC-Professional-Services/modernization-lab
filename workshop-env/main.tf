module "network_onprem" {
  providers = {
    huaweicloud = huaweicloud.crm
  }
  source   = "github.com/Huawei-APAC-Professional-Services/terraform-module/vpc"
  vpc_name = "onPrem-network"
  vpc_cidr = "10.0.0.0/16"
  subnets = [{
    name = "onprem-dmz",
    cidr = "10.0.0.0/24"
    },
    {
      name = "onprem-prod",
      cidr = "10.0.1.0/24"
    },
    {
      name = "onprem-nat"
      cidr = "10.0.2.0/24"
    }
  ]
}

resource "huaweicloud_nat_gateway" "onprem" {
  provider    = huaweicloud.crm
  name        = "onprem"
  description = "on-prem nat"
  spec        = "1"
  vpc_id      = module.network_onprem.vpc_id
  subnet_id   = module.network_onprem.subnets["onprem-nat"]
}

resource "huaweicloud_vpc_eip" "nat" {
  provider = huaweicloud.crm
  publicip {
    type = "5_bgp"
  }

  bandwidth {
    share_type  = "PER"
    name        = "onprem-nat"
    size        = 300
    charge_mode = "traffic"
  }
}

resource "huaweicloud_nat_snat_rule" "prod" {
  provider       = huaweicloud.crm
  nat_gateway_id = huaweicloud_nat_gateway.onprem.id
  floating_ip_id = huaweicloud_vpc_eip.nat.id
  subnet_id      = module.network_onprem.subnets["onprem-prod"]
}

resource "huaweicloud_vpc_peering_connection" "onprem_cloud" {
  provider    = huaweicloud.crm
  name        = "onprem-cloud"
  vpc_id      = module.network_onprem.vpc_id
  peer_vpc_id = module.network_cloud.vpc_id
}

resource "huaweicloud_vpc_route" "route_to_cloud" {
  provider    = huaweicloud.crm
  vpc_id      = module.network_onprem.vpc_id
  destination = "10.10.0.0/16"
  type        = "peering"
  nexthop     = huaweicloud_vpc_peering_connection.onprem_cloud.id
}

resource "huaweicloud_vpc_route" "route_to_onprem" {
  provider    = huaweicloud.crm
  vpc_id      = module.network_cloud.vpc_id
  destination = "10.0.0.0/16"
  type        = "peering"
  nexthop     = huaweicloud_vpc_peering_connection.onprem_cloud.id
}