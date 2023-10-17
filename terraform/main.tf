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

## NETWORK INIT

#Create ProjectNetwork
resource "openstack_networking_network_v2" "soc_network" {
  name = "soc_network"
  admin_state_up = true
}

#create subnet
resource "openstack_networking_subnet_v2" "soc_subnet" {
  name = "soc_subnet"
  network_id = openstack_networking_network_v2.soc_network.id
  cidr = "10.10.40.0/24"
  ip_version = 4

  #Subnet delegation thus far:
  #.250: Ansible
  #.200-249: Management Services
    #.201 Elastic
}

#Create ProjectNetwork
resource "openstack_networking_network_v2" "controlsys_network" {
  name = "controlsys_network"
  admin_state_up = true
}

#create subnet
resource "openstack_networking_subnet_v2" "controlsys_subnet" {
  name = "controlsys_subnet"
  network_id = openstack_networking_network_v2.controlsys_network.id
  cidr = "10.10.30.0/24"
  ip_version = 4
}

resource "openstack_networking_network_v2" "enterprise_network" {
  name = "enterprise_network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "enterprise_subnet" {
  name = "enterprise_subnet"
  network_id = openstack_networking_network_v2.enterprise_network.id
  cidr = "10.10.20.0/24"
  ip_version = 4
}

#Create ProjectNetwork
resource "openstack_networking_network_v2" "business_network" {
  name = "business_network"
  admin_state_up = true
}

#create subnet
resource "openstack_networking_subnet_v2" "business_subnet" {
  name = "business_subnet"
  network_id = openstack_networking_network_v2.business_network.id
  cidr = "10.10.10.0/24"
  ip_version = 4
}

resource "openstack_networking_port_v2" "ansible_port1" {
  name               = "ansible_port1"
  network_id         = openstack_networking_network_v2.soc_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.soc_subnet.id
    ip_address = "10.10.40.250"
  }
}


#creating port 2 and attaching to main-net to allow floating IP. 
#Once things are actually deployed and all, the only machines with a 2nd port would be the outward-facing ones.
resource "openstack_networking_port_v2" "ansible_port2" {
  name               = "ansible_port1"
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
  port_id     = openstack_networking_port_v2.ansible_port2.id
}

resource "openstack_networking_port_v2" "elasticsearch_port1" {
  name               = "elasticsearch_port1"
  network_id         = openstack_networking_network_v2.soc_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.soc_subnet.id
    ip_address = "10.10.40.201"
  }
}

### COMPUTE INIT
resource "openstack_compute_instance_v2" "ansible" {
  name              = "ansible"
  image_name        = "DebianBullseye11"
  flavor_name       = "small"
  key_pair          = "gframe"
  security_groups   = ["default"]

  user_data = templetefile("bootstrap/bootstrapansible.sh.tftpl", {
    bootstrapsshprivkey = file("bootstrap/id_bootstrap")
  })

  network {
    port = openstack_networking_port_v2.ansible_port1.id
  }
  
  network {
    port = openstack_networking_port_v2.ansible_port2.id
  }
}

resource "openstack_compute_instance_v2" "elasticsearch" {
  name              = "elasticsearch"
  image_name        = "DebianBullseye11"
  flavor_name       = "small"
  key_pair          = "gframe"
  security_groups   = ["default"]

  user_data = templatefile("bootstrap/bootstrapelastic.sh.tftpl", {
    bootstrapsshpubkey = file("bootstrap/id_bootstrap.pub")
  })

  network {
    port = openstack_networking_port_v2.elasticsearch_port1.id
  }
}