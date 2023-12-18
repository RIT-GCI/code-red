## --- Ansible --- ##
resource "openstack_networking_port_v2" "ansible_port1" {
  name               = "ansible_port1"
  network_id         = openstack_networking_network_v2.soc_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.soc_lan.id
    ip_address = "10.10.40.250"
  }
}

resource "openstack_compute_instance_v2" "ansible" {
  name              = "ansible"
  image_name        = "DebianBullseye11"
  flavor_name       = "large"
  key_pair          = "gframe"
  security_groups   = ["default"]


  user_data = templatefile("ansible/bootstrap/bootstrapansible.sh.tftpl", {
    bootstrapsshprivkey = file("ansible/bootstrap/id_bootstrap")
    playbooks = [for f in fileset(path.module, "ansible/playbooks/*.yml"): {
                        filename = f
                        content = file(f)
                   }]
    roles = [for f in fileset(path.module, "ansible/roles/**"): {
                        filename = f
                        content = file(f)
                        dirname = dirname(f)
                   }]
    "hostsfile" = file("ansible/inventory/ansiblehosts")
    secretsFilePath = file("ansible/secrets.yml")
    hostsYAML = file("ansible/inventory/hosts.yaml")
    ansibleCFG = file("ansible/ansible.cfg")
    dns_entries = file("ansible/dns/dns_entries.csv")
    ips = {
      "graylog" = openstack_networking_port_v2.graylog_port1.fixed_ip[0].ip_address,
    }
    usersshkeys = [for f in fileset(path.module, "ansible/ssh_keys/id_*.pub"): {
                        filename = f
                        content = file(f)
                   }]
  })

  network {
    port = openstack_networking_port_v2.ansible_port1.id
  }

  network {
    name = "SSHJumpNet"
    uuid = "f81a7f95-b0b3-4e97-870b-3f21c531e54f"
  }
}

#graylog-land
resource "openstack_compute_instance_v2" "graylog" {
  name              = "graylog"
  image_name        = "DebianBullseye11"
  #This will be increased as we need
  flavor_name       = "xxlarge"
  key_pair          = "gframe"
  security_groups   = ["default"]

  user_data = templatefile("ansible/bootstrap/bootstrapgraylog.sh.tftpl", {
    "bootstrapsshpubkey": file("ansible/bootstrap/id_bootstrap.pub")
    "logvolid": openstack_blockstorage_volume_v3.graylog_volume.id
  })

  network {
    port = openstack_networking_port_v2.graylog_port1.id
  }

  lifecycle {
    replace_triggered_by = [terraform_data.graylog_data]
  }
}

resource "openstack_networking_port_v2" "graylog_port1" {
  name               = "graylog_port1"
  network_id         = openstack_networking_network_v2.soc_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.soc_lan.id
    ip_address = "10.10.40.201"
  }
}

resource "openstack_blockstorage_volume_v3" "graylog_volume" {
  name        = "graylog_volume"
  description = "Volume attached to graylog"
  size        = 128
}

resource "openstack_compute_volume_attach_v2" "graylog_volume_attach" {
  instance_id = openstack_compute_instance_v2.graylog.id
  volume_id   = openstack_blockstorage_volume_v3.graylog_volume.id
}