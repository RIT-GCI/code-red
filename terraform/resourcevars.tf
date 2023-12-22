#All these variables are not meant to be used directly, instead they're used such that the correct resources
# are replaced when files are changed.
# Without this, only the ansible vm is replaced on most config changes, and that can cause some VMs to be left in a bad state.

data "dirhash_sha256" "all_linux" {
  directory = "ansible/roles/linux"
}

resource "terraform_data" "graylog_data" {
  input = sha256(join("", [
    filesha256("ansible/playbooks/installgraylog.yml"), 
    data.dirhash_sha256.all_linux.checksum
  ]))
}