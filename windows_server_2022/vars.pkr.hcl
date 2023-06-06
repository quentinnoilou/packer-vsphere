variable "vmCpuNum" {
  type    = string
  default = "2"
}

variable "vmMemSize" {
  type    = string
  default = "4096"
}

variable "vsphereCluster" {
  type    = string
  default = "Cluster1"
}

variable "floppyInitPath" {
  type    = string
  default = "./setup"
}

variable "OSVersion" {
  type    = string
  default = ""
}

variable "vsphereNetwork" {
  type    = string
  default = ""
}

variable "vSphereIsoPath" {
  type    = string
  default = "[datastore] Dir/win_2022.iso"
}

variable "vmPassword" {
  type    = string
  default = "P@ssword!"
}

variable "vmDiskSize" {
  type    = string
  default = "51200"
}

variable "vspherePassword" {
  type    = string
  default = ""
}

variable "vsphereServer" {
  type    = string
  default = ""
}

variable "vsphereUser" {
  type    = string
  default = ""
}

variable "vsphereFolder" {
  type    = string
  default = "Templates_packer"
}

variable "vsphereDatastore" {
  type    = string
  default = "Datastore"
}

variable "vsphereDatacenter" {
  type    = string
  default = "DC1"
}

variable "vmName" {
  type    = string
  default = ""
}
variable "CL" {
  type    = string
  default = ""
}