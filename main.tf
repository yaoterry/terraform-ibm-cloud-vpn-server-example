resource "ibm_is_vpc" "vpc" {
  name = "vpc-vpnserver"
}

resource "ibm_is_subnet" "subnet" {
  name                     = "mysubnet-tf"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = var.zone_name
  total_ipv4_address_count = 256
}

module "secrets-manager" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-secrets-manager"

  resource_group_name = var.resource_group_name
  region              = var.region
  ibmcloud_api_key    = var.ibmcloud_api_key
  trial               = true
  private_endpoint    = false
}


module "vpn_module" {
  source = "github.com/terraform-ibm-modules/terraform-ibm-toolkit-vpn-server"

  resource_group_name  = var.resource_group_name
  region               = var.region
  ibmcloud_api_key     = var.ibmcloud_api_key
  resource_label       = "client2site"
  secrets_manager_guid = module.secrets-manager.guid
  vpc_id               = ibm_is_vpc.vpc.id
  subnet_ids           = [ibm_is_subnet.subnet.id]
}
