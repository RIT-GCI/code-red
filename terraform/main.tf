# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
    dirhash = {
      source = "Think-iT-Labs/dirhash"
      version = "0.0.1"
    }
  }

}