locals {
    playbooks = {
        "installelastic" = file("playbooks/installelastic.yml")
    }
}

# add bootstrap ssh key:
resource "openstack_compute_keypair_v2" "bootstrap" {
  name       = "bootstrap"
  public_key = file("bootstrap/id_bootstrap.pub")
}