resource "openstack_compute_instance_v2" "ansible" {
  name              = "ansible"
  image_name        = "DebianBullseye11"
  flavor_name       = "small"
  key_pair          = "bootstrap"
  security_groups   = ["default"]


  user_data = templatefile("bootstrap/bootstrapansible.sh.tftpl", {
    bootstrapsshprivkey = file("bootstrap/id_bootstrap")
    playbooks = local.playbooks
    "hostsfile" = file("bootstrap/ansiblehosts")
    ips = {
      "elasticsearch" = openstack_networking_port_v2.elasticsearch_port1.fixed_ip[0].ip_address
    }
    secretsFilePath = file("secrets.yml")
    vaultPassFilePath = file("vault-pass.txt")
    hostsYAML = file("inventory/hosts.yaml")
  })

  network {
    port = openstack_networking_port_v2.ansible_port1.id
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

#associate floating ip to port1 on ansible
resource "openstack_networking_floatingip_associate_v2" "fip1_association" {
  floating_ip = openstack_networking_floatingip_v2.fip1.address
  port_id     = openstack_networking_port_v2.ansible_port1.id
}


resource "openstack_compute_instance_v2" "elasticsearch" {
  name              = "elasticsearch"
  image_name        = "DebianBullseye11"
  flavor_name       = "small"
  key_pair          = "bootstrap"
  security_groups   = ["default"]

  user_data = templatefile("bootstrap/bootstrapelastic.sh.tftpl", {
    "bootstrapsshpubkey": file("bootstrap/id_bootstrap.pub")
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