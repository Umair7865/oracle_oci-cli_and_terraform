provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.oci_private_key  # Path to the private key file
  region           = var.region
}

#terraform {
#  required_providers {
#    oci = {
#      source  = "oracle/oci"
#      version = "~> 6.21.0"
#    }
#  }
#}



resource "oci_core_instance" "vm_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = var.shape
  display_name        = var.vm_display_name   # name getting through github actions "github.event.inputs.vm_name"

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
    private_key = file(var.ssh_private_key_path)  # Ensure this variable is correctly defined
    host        = self.public_ip
  }

  inline = [
    <<-EOT
      #!/bin/bash
      set -e  # Exit immediately if a command exits with a non-zero status

      # Disable unattended upgrades temporarily
      sudo systemctl stop unattended-upgrades
      sudo systemctl disable unattended-upgrades

      # Avoid prompts for restarting services
      sudo apt-get -y remove --purge unattended-upgrades
      echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
      export DEBIAN_FRONTEND=noninteractive

      # Installing OCI CLI
      curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh | bash -s -- --accept-all-defaults
      source $HOME/.bashrc  # Load OCI CLI into the current shell
      python3 -m pip install --upgrade pip

      # Installing Kubectl
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      chmod +x ./kubectl
      sudo mv ./kubectl /usr/local/bin/kubectl
      kubectl version --client
      sudo apt-get install -y bash-completion
      echo 'source <(kubectl completion bash)' >>~/.bashrc
      source ~/.bashrc

      # MySQL Client Installation
      sudo apt-get install -y mysql-client

      # Installation Net Tools
      sudo apt-get install -y net-tools

      # Create the .oci directory and files
      mkdir -p $HOME/.oci
      touch $HOME/.oci/config
      touch $HOME/.oci/private.key

      # Set ownership and permissions
      sudo chown -R ubuntu:ubuntu $HOME/.oci
      sudo chmod 700 $HOME/.oci
      sudo chmod 600 $HOME/.oci/config
      sudo chmod 600 $HOME/.oci/private.key

      # Write the private key and config content from variables into the .oci directory
      echo '${var.oci_private_key}' | sudo tee $HOME/.oci/private.key > /dev/null
      echo '${var.oci_config_content}' | sudo tee $HOME/.oci/config > /dev/null

      # Add Docker's official GPG key:
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc

      # Add the repository to Apt sources:
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

      # Install Docker
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

      # Re-enable unattended upgrades after completion
      sudo apt-get -y install unattended-upgrades
      sudo systemctl enable unattended-upgrades
      sudo systemctl start unattended-upgrades
    EOT
  ]
}

# Define the variables required by Terraform

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
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
  description = "SSH public key content for VM access stored into VM directly"
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key which is stored in self-hosted Runner used for remote access by Terraform and install necessary packages for OKE"
}

# Declare the variables for private key and config file content
variable "oci_private_key" {
  description = "The private key content to be stored in the .oci directory of VM which is created using this code"
  type        = string
  #sensitive   = true  # Marks the variable as sensitive
}

variable "oci_config_content" {
  description = "The OCI config file content is stored into VM which is created using this code"
  type        = string
  #sensitive   = true  # Marks the variable as sensitive
}
