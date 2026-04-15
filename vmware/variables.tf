##### VMWARE VSPHERE ENVIRONMENT #####
variable "vsphere_server" {
  type    = string
  default = "vcenter.caverna.local"
}

variable "username" {
  type    = string
  default = "administrator@vsphere.local"
}

variable "password" {
  type      = string
  default   = "cnzTT@22"
  sensitive = true
}

variable "allow_unverified_ssl" {
  type    = bool
  default = true
}

##### INFRASTRUCTURE #####
variable "datacenter_name" {
  type    = string
  default = "Caverna Cloud"
}

variable "cluster_name" {
  type    = string
  default = "nuc-compute"
}

variable "datastore_name" {
  type    = string
  default = "NUC01_GOLD_DS_01"
}

variable "network_name" {
  type    = string
  default = "VLAN10_192.168.10.0"
}

variable "template_name" {
  type    = string
  default = "Ubuntu 24.04"
}

variable "dns_servers" {
  type    = list(string)
  default = ["192.168.10.1"]
}

##### VIRTUAL MACHINES #####
variable "vms" {
  type = map(object({
    vm_name                 = string
    vm_annotation           = string
    vm_cpu                  = number
    vm_memory               = number
    vm_disk_label           = string
    vm_custom_domain        = string
    vm_custom_ip_address    = string
    vm_custom_mask          = number
    vm_custom_ip_gateway    = string
  }))
  default = {
    vm1 = {
      vm_name              = "kub01"
      vm_annotation        = "Microk8s node 01"
      vm_cpu               = 2
      vm_memory            = 6144
      vm_disk_label        = "disk0"
      vm_custom_domain     = "caverna.local"
      vm_custom_ip_address = "192.168.10.91"
      vm_custom_mask       = 24
      vm_custom_ip_gateway = "192.168.10.250"
    },
    vm2 = {
      vm_name              = "kub02"
      vm_annotation        = "Microk8s node 02"
      vm_cpu               = 2
      vm_memory            = 6144
      vm_disk_label        = "disk0"
      vm_custom_domain     = "caverna.local"
      vm_custom_ip_address = "192.168.10.92"
      vm_custom_mask       = 24
      vm_custom_ip_gateway = "192.168.10.250"
	},
    vm3 = {
      vm_name              = "kub03"
      vm_annotation        = "Microk8s node 03"
      vm_cpu               = 2
      vm_memory            = 6144
      vm_disk_label        = "disk0"
      vm_custom_domain     = "caverna.local"
      vm_custom_ip_address = "192.168.10.93"
      vm_custom_mask       = 24
      vm_custom_ip_gateway = "192.168.10.250"
    }
  }
}