##### PROVIDER #####
terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      #version = "2.6.1"
    }
  }
}

provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.username
  password             = var.password
  allow_unverified_ssl = var.allow_unverified_ssl
}

##### DATA #####
data "vsphere_datacenter" "datacenter" {
  name = var.datacenter_name
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

##### RESOURCE #####
resource "vsphere_virtual_machine" "vm" {
  for_each = var.vms

  name             = each.value.vm_name
  annotation       = each.value.vm_annotation
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = each.value.vm_cpu
  memory           = each.value.vm_memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  disk {
    label            = each.value.vm_disk_label
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = each.value.vm_name
        domain    = each.value.vm_custom_domain
      }
      network_interface {
        ipv4_address = each.value.vm_custom_ip_address
        ipv4_netmask = each.value.vm_custom_mask
      }
      ipv4_gateway = each.value.vm_custom_ip_gateway
	  dns_server_list = var.dns_servers
    }
  }
}