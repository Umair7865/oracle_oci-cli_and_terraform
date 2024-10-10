provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

resource "oci_core_instance" "vm_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = var.shape
  display_name = var.vm_display_name
}

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  shape_config {
    memory_in_gbs = var.memory_in_gbs
    ocpus         = var.ocpus
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key  # Passing public key content directly
  }

provisioner "remote-exec" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = self.public_ip
  }

  inline = [
      "echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections",
      "export DEBIAN_FRONTEND=noninteractive",
      "curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh | bash -s -- --accept-all-defaults",
      "python3 -m pip install --upgrade pip",
      "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"",
      "chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
      "kubectl version --client",
      "sudo apt-get install -y bash-completion",
      "echo 'source <(kubectl completion bash)' >>~/.bashrc",
      "source ~/.bashrc",
      "mkdir -p $HOME/.kube"
  ]
}

# Define the variables required by Terraform

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_id" {}
variable "availability_domain" {}
variable "shape" { default = "VM.Standard.E5.Flex" }
variable "vm_display_name" { default = "MyTerraformVM" }
variable "subnet_id" {}
variable "image_id" {}
variable "ocpus" { default = 1 }
variable "memory_in_gbs" { default = 2 }
variable "ssh_public_key" {
  description = "SSH public key content for VM access"
}
variable "ssh_private_key_path" {
  description = "Path to the SSH private key used for remote access"
}
