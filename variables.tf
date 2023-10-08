variable "openstack_username" {
    description = "OpenStack username"
    type = string
}

#Can't find a sane way to do auth via tokens...
variable "openstack_password" {
    description = "OpenStack password"
    type = string
}

variable "openstack_auth_url" {
    description = "OpenStack auth url"
    type = string
    default = "https://openstack.cyberrange.rit.edu:5000"
}

