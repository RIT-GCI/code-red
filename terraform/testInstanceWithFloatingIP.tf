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