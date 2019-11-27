variable "x" {
    default = "1"
}

variable "vm_name" {}
variable "client_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "rg_name" {}
variable "vn_name" {}
variable "sn_name" {}
variable "nsg" {}
variable "pip" {}
variable "vm_size" {}
variable "image" {}

provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
}

data "azurerm_resource_group" "rg" {
    name     = "${var.rg_name}"
}

data "azurerm_virtual_network" "vn" {
    name                = "${var.vn_name}"
    resource_group_name = "${data.azurerm_resource_group.rg.name}"
}

data "azurerm_subnet" "sn" {
    name                 = "${var.sn_name}"
    resource_group_name = "${data.azurerm_resource_group.rg.name}"
    virtual_network_name = "${data.azurerm_virtual_network.vn.name}"
}

data "azurerm_public_ip" "windows_pip" {
    name                = "${var.pip}"
    resource_group_name = "${data.azurerm_resource_group.rg.name}"
}

data "azurerm_network_security_group" "nsg" {
    name                = "${var.nsg}"
    resource_group_name = "${data.azurerm_resource_group.rg.name}"
}

resource "azurerm_network_interface" "main" {
    name                = "WTFNIC${count.index}"
    location            = "${data.azurerm_resource_group.rg.location}"
    resource_group_name = "${data.azurerm_resource_group.rg.name}"
    network_security_group_id = "${data.azurerm_network_security_group.nsg.id}"
    count = "${var.x}"

    ip_configuration {
        name                          = "myNicConfig${count.index}"
        subnet_id                     = "${data.azurerm_subnet.sn.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${data.azurerm_public_ip.windows_pip.id}"
    }
}

resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "${var.vm_name}${count.index}"
    location              = "${data.azurerm_resource_group.rg.location}"
    resource_group_name   = "${data.azurerm_resource_group.rg.name}"
    network_interface_ids = ["${element(azurerm_network_interface.main.*.id, count.index)}"]
    vm_size               = "${var.vm_size}"
    count                 = "${var.x}"

    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_os_disk {
        name              = "WOsDisk${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "${var.image}"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "azureuser"
        admin_password = "Xyzabc123@"
        custom_data    = "${file("${path.module}/winrm.ps1")}"
    }

    os_profile_windows_config {
        provision_vm_agent = "true"
        timezone           = "Romance Standard Time"
        winrm {
          protocol = "http"
        }

        additional_unattend_config {
          pass         = "oobeSystem"
          component    = "Microsoft-Windows-Shell-Setup"
          setting_name = "AutoLogon"
          content      = "<AutoLogon><Password><Value>Xyzabc123@</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>azureuser</Username></AutoLogon>"
        }
        additional_unattend_config {
          pass         = "oobeSystem"
          component    = "Microsoft-Windows-Shell-Setup"
          setting_name = "FirstLogonCommands"
          content      = "${file("${path.module}/FirstLogonCommands.xml")}"
        }
    }

    provisioner "remote-exec" {
        connection {
          host     = "${azurerm_public_ip.windows_pip.ip_address}"
          type     = "winrm"
          port     = 5985
          https    = false
          timeout  = "5m"
          user     = "azureuser"
          password = "Xyzabc123@"
        }
        inline = [
          "powershell.exe -ExecutionPolicy Unrestricted -Command {Install-WindowsFeature -name Web-Server -IncludeManagementTools}",
        ]
    }

}