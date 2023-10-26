locals {
    playbooks = {
        "installelastic.yml" = file("playbooks/installelastic.yml")
        "setsshkeys.yml" = file("playbooks/setsshkeys.yml")
        "main.yml" = file("playbooks/main.yml")
        "domain_controller.yml" = file("playbooks/domain_controller.yml")
    }
    ansiblehostfile = file("bootstrap/ansiblehosts")
}

# add bootstrap ssh key:
resource "openstack_compute_keypair_v2" "bootstrap" {
  name       = "bootstrap"
  public_key = file("bootstrap/id_bootstrap.pub")
}