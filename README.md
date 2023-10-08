Mostly just test terraform configs for now. Hopefully this will be moved to a repo under the org soon



## Setup:

1. Install terraform (once there are releases of OpenTofu we will switch to using that. It should be completely compatible and any required changes will be made for the transition.)
1. Create an application credential inside of openstack
1. Create vars.tfvars file with the following contents:
    ```
    username = "your_username"
    openstack_application_credential_secret="your_application_credential_secret"
    openstack_application_credential_name = "your_application_credential_name"
    ```
1. Run `terraform plan` to ensure that the changes terraform will make are what you expect
1. Run `terraform apply` to apply the changes