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
  auth_url    = var.openstack_auth_url
  tenant_id     = var.openstack_project_id
  user_domain_name = var.openstack_user_domain_name
  region = var.openstack_region_name
  project_domain_id = var.openstack_project_domain_id
  allow_reauth = false

}

## NETWORK INIT


#Create ProjectNetwork
resource "openstack_networking_network_v2" "project_network" {
  name = "project_network"
  admin_state_up = true
}

#create subnet
resource "openstack_networking_subnet_v2" "project_subnet" {
  name = "project_subnet"
  network_id = openstack_networking_network_v2.project_network.id
  cidr = "10.13.137.0/24"
  ip_version = 4
}

resource "openstack_networking_port_v2" "testubu_port1" {
  name               = "testubu_port1"
  network_id         = openstack_networking_network_v2.project_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.project_subnet.id
    ip_address = "10.13.137.10"
  }
}

#creating port 2 and attaching to main-net to allow floating IP.
#Once things are actually deployed and all, the only machines with a 2nd port would be the outward-facing ones.
resource "openstack_networking_port_v2" "testubu_port2" {
  name               = "testubu_port1"
  network_id         = var.openstack_mainnet_id
  admin_state_up     = "true"

}

#create floating IP
resource "openstack_networking_floatingip_v2" "fip1" {
  pool = "external249"
}

#associate floating ip to port2
resource "openstack_networking_floatingip_associate_v2" "fip1_association" {
  floating_ip = openstack_networking_floatingip_v2.fip1.address
  port_id     = openstack_networking_port_v2.testubu_port2.id
}

### COMPUTE INIT
resource "openstack_compute_instance_v2" "testubu" {
  name              = "testubu"
  image_name        = "UbuntuJammy2204"
  flavor_name       = "small"
  key_pair          = "gframe"
  security_groups   = ["default"]


  network {
    port = openstack_networking_port_v2.testubu_port1.id
  }

  network {
    port = openstack_networking_port_v2.testubu_port2.id
  }
}