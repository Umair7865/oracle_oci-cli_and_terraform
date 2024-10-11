resource "oci_core_instance" "vm_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = var.shape
  display_name        = var.vm_display_name  # name will pass here after workflow dispatch

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
      "echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections",  # Avoid restart prompts
      "export DEBIAN_FRONTEND=noninteractive",  # Ensure non-interactive mode for apt
      "curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh | bash -s -- --accept-all-defaults",
      "python3 -m pip install --upgrade pip",
      "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"",
      "chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
      "kubectl version --client",
      "sudo apt-get install -y bash-completion",
      "echo 'source <(kubectl completion bash)' >>~/.bashrc",
      ". ~/.bashrc",
         
      # Create the .oci directory and files
      "sudo mkdir -p $HOME/.oci",              # Create the directory
      "sudo touch $HOME/.oci/config",           # Create the config file
      "sudo touch $HOME/.oci/private.key",      # Create the private key file

      # Set ownership and permissions
      "sudo chown -R ubuntu:ubuntu $HOME/.oci", # Set ownership to ubuntu for all files in .oci
      "sudo chmod 700 $HOME/.oci",              # Set the correct permissions for the directory
      "sudo chmod 600 $HOME/.oci/config",       # Set the correct permissions for the config file
      "sudo chmod 600 $HOME/.oci/private.key",   # Set the correct permissions for the private key file

      # Write the private key and config content from variables into the .oci directory
      "echo '${var.oci_private_key}' | sudo tee $HOME/.oci/private.key > /dev/null",
      "echo '${var.oci_config_content}' | sudo tee $HOME/.oci/config > /dev/null"
    ]
  }
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
  description = "SSH public key content for VM access"
}
variable "ssh_private_key_path" {
  description = "Path to the SSH private key used for remote access"
}

# Declare the variables for private key and config file content
variable "oci_private_key" {
  description = "The private key content to be stored in the .oci directory"
  type        = string
  #sensitive   = true  # Marks the variable as sensitive
}

variable "oci_config_content" {
  description = "The OCI config file content"
  type        = string
  #sensitive   = true  # Marks the variable as sensitive
}
