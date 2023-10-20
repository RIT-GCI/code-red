resource "openstack_compute_instance_v2" "ansible" {
  name              = "ansible"
  image_name        = "DebianBullseye11"
  flavor_name       = "small"
  key_pair          = "gframe"
  security_groups   = ["default"]

  #not sure why this is needed but I got an error about it being invalid when it was undefined.
  power_state = "active"

  user_data = templatefile("bootstrap/bootstrapansible.sh.tftpl", {
    bootstrapsshprivkey = file("bootstrap/id_bootstrap")
    playbooks = local.playbooks

  })

  network {
    port = openstack_networking_port_v2.ansible_port1.id
  }
  
  network {
    port = openstack_networking_port_v2.ansible_port2.id
  }
}

resource "openstack_networking_port_v2" "ansible_port1" {
  name               = "ansible_port1"
  network_id         = openstack_networking_network_v2.soc_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.soc_lan.id
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

#associate floating ip to port2
resource "openstack_networking_floatingip_associate_v2" "fip1_association" {
  floating_ip = openstack_networking_floatingip_v2.fip1.address
  port_id     = openstack_networking_port_v2.ansible_port2.id
}




resource "openstack_compute_instance_v2" "elasticsearch" {
  name              = "elasticsearch"
  image_name        = "DebianBullseye11"
  flavor_name       = "small"
  key_pair          = "gframe"
  security_groups   = ["default"]

  user_data = templatefile("bootstrap/bootstrapelastic.sh.tftpl", {
  })

  network {
    port = openstack_networking_port_v2.elasticsearch_port1.id
  }
}

resource "openstack_networking_port_v2" "elasticsearch_port1" {
  name               = "elasticsearch_port1"
  network_id         = openstack_networking_network_v2.soc_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.soc_lan.id
    ip_address = "10.10.40.201"
  }
}