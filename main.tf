# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  application_credential_secret    = var.openstack_application_credential_secret
  application_credential_name = var.openstack_application_credential_name
  user_name      = var.openstack_username
  auth_url    = var.openstack_auth_url
  tenant_id     = var.openstack_project_id
  user_domain_name = var.openstack_user_domain_name
  region = var.openstack_region_name
  project_domain_id = var.openstack_project_domain_id
  allow_reauth = false
  
}


resource "openstack_compute_instance_v2" "testubu" {
  name              = "testubu"
  image_name        = "UbuntuJammy2204"
  flavor_name       = "small"
  key_pair          = "gframe"
  security_groups   = ["default"]


  network {
    name = "MAIN-NAT"
  }
}