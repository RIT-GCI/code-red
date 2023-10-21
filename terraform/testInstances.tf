resource "openstack_networking_port_v2" "testPortBusinessLan" {
  name               = "testPortBusinessLan"
  network_id         = openstack_networking_network_v2.business_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.business_lan.id
    ip_address = "10.10.10.10"
  }
}

resource "openstack_compute_instance_v2" "testInstanceBusinessLan" {
  name              = "testInstanceLinux"
  image_name        = "CentOS7.9"
  flavor_name       = "medium"
  security_groups   = ["default"]

  network {
    port = openstack_networking_port_v2.testPortBusinessLan.id
  }
}


resource "openstack_networking_port_v2" "testPortEnterpriseLan" {
  name               = "testInstanceEnterpriseLan"
  network_id         = openstack_networking_network_v2.enterprise_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.enterprise_lan.id
    ip_address = "10.10.20.20"
  }
}

resource "openstack_compute_instance_v2" "testInstanceEnterpriseLanLinux" {
  name              = "testInstanceEnterpriseLan"
  image_name        = "CentOS7.9"
  flavor_name       = "medium"
  security_groups   = ["default"]

  network {
    port = openstack_networking_port_v2.testPortEnterpriseLan.id
  }
}

resource "openstack_networking_port_v2" "testPortControlRoomLan" {
  name               = "testPortControlRoomLan"
  network_id         = openstack_networking_network_v2.control_room_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.control_room_lan.id
    ip_address = "10.10.30.30"
  }
}

resource "openstack_compute_instance_v2" "testInstanceControlRoomLan" {
  name              = "testInstanceControlRoomLinux"
  image_name        = "CentOS7.9"
  flavor_name       = "medium"
  security_groups   = ["default"]

  network {
    port = openstack_networking_port_v2.testPortControlRoomLan.id
  }
}

resource "openstack_networking_port_v2" "testPortSOCLan" {
  name               = "testPortSOCLan"
  network_id         = openstack_networking_network_v2.soc_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.soc_lan.id
    ip_address = "10.10.40.40"
  }
}

resource "openstack_compute_instance_v2" "testInstanceSOCLan" {
  name              = "testInstanceSOCLanLinux"
  image_name        = "CentOS7.9"
  flavor_name       = "medium"
  security_groups   = ["default"]

  network {
    port = openstack_networking_port_v2.testPortSOCLan.id
  }
}
