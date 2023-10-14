resource "openstack_networking_router_v2" "router" {
  name           = "router"
  admin_state_up = "true"

}

# resource "openstack_networking_network_v2" "externalNetwork" {
#   name           = "externalNetwork"
#   admin_state_up = "true"
# }

resource "openstack_networking_network_v2" "internalNetwork"{
  name = "internalNetwork"
  admin_state_up = "true"
}

# subnet pool for the whole of internal network
# consists of the Business LAN, Enterprise LAN, Control System LAN, SOC/Monitoring LAN
resource "openstack_networking_subnetpool_v2" "internalNetworkPool" {
  name = "internalNetworkPool"
  prefixes = ["10.10.0.0/16"]
}

# external network may consist of AD/DC
# resource "openstack_networking_subnet_v2" "externalNetwork_subnet_1" {
#   network_id = openstack_networking_network_v2.externalNetwork.id
#   cidr       = "192.168.101.0/24"
#   ip_version = 4
# }

# resource "openstack_networking_router_interface_v2" "router_external_interface" {
#   router_id = openstack_networking_router_v2.router.id
#   subnet_id = openstack_networking_subnet_v2.externalNetwork_subnet_1.id
# }


resource "openstack_networking_subnet_v2" "business_lan" {
  name          = "business_lan"
  cidr          = "10.10.10.0/24"
  network_id    = openstack_networking_network_v2.internalNetwork.id
  subnetpool_id = openstack_networking_subnetpool_v2.internalNetworkPool.id
}

resource "openstack_networking_router_interface_v2" "router_business_lan_interface"{
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.business_lan.id
}

resource "openstack_networking_subnet_v2" "enterprise_lan" {
  name          = "enterprise_lan"
  cidr          = "10.10.20.0/24"
  network_id    = openstack_networking_network_v2.internalNetwork.id
  subnetpool_id = openstack_networking_subnetpool_v2.internalNetworkPool.id
}

resource "openstack_networking_router_interface_v2" "router_enterprise_lan_interface"{
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.enterprise_lan.id
}

resource "openstack_networking_subnet_v2" "control_room_lan" {
  name          = "control_room_lan"
  cidr          = "10.10.30.0/24"
  network_id    = openstack_networking_network_v2.internalNetwork.id
  subnetpool_id = openstack_networking_subnetpool_v2.internalNetworkPool.id
}

resource "openstack_networking_router_interface_v2" "router_control_room_lan_interface"{
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.control_room_lan.id
}

resource "openstack_networking_subnet_v2" "soc_lan" {
  name          = "soc_lan"
  cidr          = "10.10.40.0/24"
  network_id    = openstack_networking_network_v2.internalNetwork.id
  subnetpool_id = openstack_networking_subnetpool_v2.internalNetworkPool.id
}

resource "openstack_networking_router_interface_v2" "router_soc_lan_interface"{
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.soc_lan.id
}


# resource "openstack_networking_router_route_v2" "router_route_1" {
#   depends_on       = [openstack_networking_router_interface_v2.router_internal_interface]
#   router_id        = openstack_networking_router_v2.router.id
#   destination_cidr = "10.0.1.0/24"
#   next_hop         = "192.168.101.254"
# }

# resource "openstack_networking_router_route_v2" "router_route_2" {
#   depends_on       = [openstack_networking_router_interface_v2.router_internal_interface]
#   router_id        = openstack_networking_router_v2.router.id
#   destination_cidr = "10.0.1.0/24"
#   next_hop         = "192.168.101.254"
# }
