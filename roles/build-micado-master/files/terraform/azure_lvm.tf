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
variable "vm_size" {}
variable "image" {}
variable "key_data" {}

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

data "azurerm_network_security_group" "nsg" {
    name                = "${var.nsg}"
    resource_group_name = "${data.azurerm_resource_group.rg.name}"
}

resource "azurerm_network_interface" "main" {
    name                = "TNIC${count.index}"
    location            = "${data.azurerm_resource_group.rg.location}"
    resource_group_name = "${data.azurerm_resource_group.rg.name}"
    network_security_group_id = "${data.azurerm_network_security_group.nsg.id}"
    count = "${var.x}"

    ip_configuration {
        name                          = "myNicConfiguration${count.index}"
        subnet_id                     = "${data.azurerm_subnet.sn.id}"
        private_ip_address_allocation = "Dynamic"
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
        name              = "myOsDisk${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "${var.image}"
        version   = "latest"
    }

        os_profile {
        computer_name  = "myvm"
        admin_username = "azureuser"
        custom_data    = "${file("${path.module}/cloud-init.yaml")}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "${var.key_data}"
        }

    }
}