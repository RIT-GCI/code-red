# Configure the OpenStack Provider
provider "openstack" {
  application_credential_secret    = var.openstack_application_credential_secret
  application_credential_name = var.openstack_application_credential_name
  auth_url    = var.openstack_auth_url
  tenant_id     = var.openstack_project_id
  user_domain_name = var.openstack_user_domain_name
  region = var.openstack_region_name
  project_domain_id = var.openstack_project_domain_id
  allow_reauth = false
  user_name = var.openstack_username
}