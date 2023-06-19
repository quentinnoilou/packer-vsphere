locals {
  build_by      = "Built by: HashiCorp Packer ${packer.version}"
  build_date    = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_version = formatdate("MMDD.hhmm", timestamp())
}

source "vsphere-iso" "WS2022" {

  // Nom de la VM et système invité (Windows Server 2022)
  vm_name = "WS2022" 
  guest_os_type = "windows9Server64Guest"

  // Config de la machine
  CPUs                 = "${var.vmCpuNum}"
  RAM                  = "${var.vmMemSize}"
  disk_controller_type = ["lsilogic-sas"]
  firmware             = "bios"
  network_adapters {
    network      = "${var.vsphereNetwork}"
    network_card = "vmxnet3"
  }
  storage {
    disk_size             = "${var.vmDiskSize}"
    disk_thin_provisioned = true
  }
  remove_cdrom = "true"

  // ISO Source et checksum (Get-FileHash)
  // Le path peut être soit local soit sur le vsphere dans un datastore
  iso_paths            = ["${var.vSphereIsoPath}", "[] /vmimages/tools-isoimages/windows.iso"] # "[Datastore] Dossier/fichier.iso"
  iso_checksum = "md5:290B43B5A6FE9B52B561D34EB92E8003" # à modifier selon votre iso
  
  // Config sur vSphere
  datacenter           = "${var.vsphereDatacenter}"
  datastore            = "${var.vsphereDatastore}"
  folder               = "${var.vsphereFolder}"
  cluster              = "${var.vsphereCluster}"

  
  // Config de connexion à vSphere
  username       = "${var.vsphereUser}"
  password     = "${var.vspherePassword}"
  vcenter_server = "${var.vsphereServer}"
  // Décommenter cette option si vous n'avez pas de certificat sur votre vCenter
  # insecure_connection  = "true"

  // Dossier contenant les scripts (sera monté en A:\)
  floppy_files         = ["${var.floppyInitPath}"]
  
  // Config WinRM
  communicator         = "winrm"
  winrm_username = "Administrateur"
  winrm_password = "${var.vmPassword}"
  winrm_insecure = true
  # winrm_timeout =  "30m"

  // Config Bibliothèque de contenu
  content_library_destination {
    library = "${var.CL}"
    ovf     = "true"
  }

  // Commande pour arrêter le système (ici, on effectue un SYSPREP avant l'arrêt) 
  // arrêt seul : shutdown_command = "shutdown /s /t 30 /f"
  shutdown_command = "C:\\Windows\\system32\\Sysprep\\sysprep.exe /generalize /oobe /shutdown /unattend:a:\\sysprep-autounattend.xml"
  shutdown_timeout = "60m"
}

build {
  sources = ["source.vsphere-iso.WS2022"]

  // Hardening de Windows
  provisioner "powershell" {
    script = "${path.root}/setup/harden_windows.ps1"
  } 

  // Initier un redémarrage de la machine
  provisioner "windows-restart" {
    restart_timeout = "10m"
  }
}
