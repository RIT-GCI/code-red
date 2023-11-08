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

variable "openstack_username" {
    description = "OpenStack application credential name"
    type = string
}

variable "windows_admin_username"{
    description = "Username for the local admin"
    type = string
    default = "Administrator"
}

variable "windows_admin_password" {
    description = "Password for the local admin"
    type        = string
    default     = "password"
}

variable "ansible_user"{
    description = "User for ansible"
    type        = string
    default     = "ansible"
}

variable "ansible_password"{
    description = "Password for the ansible user"
    type        = string
    default     = "ansible"
}

variable "ansible_ip_address"{
    description = "IP Address for the ansible instance"
    type        = string
    default     = "10.10.40.250"
}