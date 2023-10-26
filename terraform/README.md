# README

Terraform configs for Code Red. Once OpenTofu has a stable release we will switch to using that. As it should be completely backwards compatible with terraform, we're just going to start with using terraform.

## Setup

1. Install terraform (once there are releases of OpenTofu we will switch to using that. It should be completely compatible and any required changes will be made for the transition)
1. Create an application credential inside of openstack
1. Create vars.tfvars file with the following contents:

    ```YML
    username = "your_username"
    openstack_application_credential_secret="your_application_credential_secret"
    openstack_application_credential_name = "your_application_credential_name"
    ```

1. Run `terraform plan -var-file vars.tfvars` to ensure that the changes terraform will make are what you expect
1. Run `terraform apply -var-file vars.tfvars` to apply the changes
1. Run `terraform destroy -var-file vars.tfvars` to destroy the changes once you are done with them (note that you can run apply multiple times without destroying and only the difference between what's in openstack and the state file will be applied)

## Security notes

- Currently, there is a bootstrap private key stored publicly. This is kept here to be simpler to manage and as soon as Ansible is used to bootstrap the servers, it will be removed.

## Ansible Vault

Ansible Vault can be used to encrypt and decrypt secrets.

Currently, ansible vault is being used to store variables for the domain controller. If storing any passwords/keys we can use the vault to encrypt it when pushing to Github.

- Files can be encrypted using `ansible-vault encrypt ${filename}`.
- Files can be decrypted using `ansible-vault decrypt ${filename}`.
- Files can be edited using `ansible-vault edit ${filename}`.
- All of the above will ask for password with a prompt.
- `--vault-password-file=${password_file_location}` can be used in conjunction with the above commands to provide plain-text password through a file.
- `ansible-playbook -i /playbooks/{playbook}.yml --vault-password-file={vault-pass-file}.txt` can be used to provide the playbook with the vault password.
- `ansible-vault encrypt_string "{some_string}" --name {some_name}` can be used to create secret variables.

## File layout

- Instances should be categorized by their general domain (soc, etc)
- Instance files should have the port, floating IP associations, and instance definitions
- router.tf should have network definitions, including Floating IP definitions
- templatevars.tf contains definitions for variables that are used in templates (as they can be quite large)
