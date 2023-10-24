variable "openstack_application_credential_secret" {
    description = "OpenStack token"
    type = string
}

variable "openstack_application_credential_name" {
    description = "OpenStack application credential name"
    type = string
}


variable "openstack_auth_url" {
    description = "OpenStack auth url"
    type = string
    # for some reason if you don't add /v3 it uses port 443...
    # this took at least an hour to figure out
    default = "https://openstack.cyberrange.rit.edu:5000/v3"
}

# variable "openstack_project_name" {
#     description = "OpenStack project ID"
#     type = string
#     default = "code-red"
# }

variable "openstack_project_id" {
    description = "OpenStack project ID"
    type = string
    default = "b086544404524220a92e43294a253c68"
}

variable "openstack_user_domain_name" {
    description = "OpenStack domain name"
    type = string
    default = "Default"
}

variable "openstack_region_name" {
    description = "OpenStack region name"
    type = string
    default = "gibson"
}

variable "openstack_project_domain_id" {
    description = "OpenStack project domain ID"
    type = string
    default = "default"
}

# No longer in use because this causes issues, the router now has a gateway to external249
# variable "openstack_mainnet_id" {
#     description = "ID of the MAINNET network, used for the floating IP"
#     type = string
#     default = "69729743-b5e4-4f1a-a978-626d2769e2e1"
# }

variable "openstack_username" {
    description = "OpenStack application credential name"
    type = string
}