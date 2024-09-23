module "network_cloud" {
  providers = {
    huaweicloud = huaweicloud.crm
  }
  source   = "github.com/Huawei-APAC-Professional-Services/terraform-module/vpc"
  vpc_name = "oncloud-network"
  vpc_cidr = "10.10.0.0/16"
  subnets = [{
    name = "cloud-elb",
    cidr = "10.10.0.0/24"
    },
    {
      name = "cloud-app",
      cidr = "10.10.1.0/24"
    },
    {
      name = "cloud-db"
      cidr = "10.10.2.0/24"
    }
  ]
}