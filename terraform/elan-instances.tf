resource "openstack_networking_port_v2" "elan-winhost-01-port1" {
  name               = "elan-winhost-01-port1"
  network_id         = openstack_networking_network_v2.enterprise_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.enterprise_lan.id
    ip_address = "10.10.20.32"
  }
}


resource "openstack_compute_instance_v2" "elan-winhost-01" {
  name              = "elan-winhost-01"
  image_name        = "Win11-21H2"
  flavor_name       = "medium"
  key_pair          = "skp"
  security_groups   = ["default"]

  network {
    port = openstack_networking_port_v2.elan-winhost-01-port1.id
  }

  user_data = <<EOF
		<powershell>
		#  set password complexity to 0 for testing
		secedit /export /cfg c:\secpol.cfg
		(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
		secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
		rm -force c:\secpol.cfg -confirm:$false

		# change the local admin password
		$admin = [adsi]("WinNT://./${var.windows_admin_username}, user")
		$admin.PSBase.Invoke("SetPassword", "${var.windows_admin_password}")

		# set firewall rules and such for ansible
		Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/AlbanAndrieu/ansible-windows/master/files/ConfigureRemotingForAnsible.ps1'))

		# add the ansible user and set it to password then make it admin
		net user ${var.ansible_user} ${var.ansible_password} /logonpasswordchg:no /active:yes /add
		net localgroup administrators ansible /add

		</powershell>
		EOF
}


resource "openstack_networking_port_v2" "elan-winsrv-01-port1" {
  name               = "elan-winsrv-01-port1"
  network_id         = openstack_networking_network_v2.enterprise_network.id
  admin_state_up     = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.enterprise_lan.id
    ip_address = "10.10.20.16"
  }
}


resource "openstack_compute_instance_v2" "elan-winsrv-01" {
  name              = "elan-winsrv-01"
  image_name        = "WinSrv2022-20348-2022"
  flavor_name       = "medium"
  key_pair          = "skp"
  security_groups   = ["default"]

  network {
    port = openstack_networking_port_v2.elan-winsrv-01-port1.id
  }

  user_data = <<EOF
		<powershell>
		#  set password complexity to 0 for testing
		secedit /export /cfg c:\secpol.cfg
		(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
		secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
		rm -force c:\secpol.cfg -confirm:$false

		# change the local admin password
		$admin = [adsi]("WinNT://./${var.windows_admin_username}, user")
		$admin.PSBase.Invoke("SetPassword", "${var.windows_admin_password}")

		# set firewall rules and such for ansible
		Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/AlbanAndrieu/ansible-windows/master/files/ConfigureRemotingForAnsible.ps1'))

		# add the ansible user and set it to password then make it admin
		net user ${var.ansible_user} ${var.ansible_password} /logonpasswordchg:no /active:yes /add
		net localgroup administrators ansible /add

		</powershell>
		EOF
}