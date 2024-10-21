### [Click ME to View _Self Hosted Runner Details_](https://github.com/Umair7865/self-hosted_runner?tab=readme-ov-file#how-to-create-your-own-self-hosted-runner-for-github-actions)

**********************************************************************
This file can create bastion host in oracle cloud with 1-CPU and 2-GB RAM, just provide secrets within github secrets.

**Username** = "ubuntu"

**Private key** = "create a public and private key using shh-keygen and place the public key within github secrets and use private key to access that instance"

## For Creating Bastion-host using github actions:
please make sure the below priority things according to your environment
- `OCI_TENANCY_OCID`          ( Enter tenancy OCID )
- `OCI_USER_OCID`             ( Enter OCID of user )
- `OCI_KEY_FINGERPRINT`       ( Enter Fingerprint from go to **My profile** _(top right corner)_ --- go to **API keys** )
- `OCI_REGION`                ( Enter region like "me-jeddah-1" )
- `OCI_COMPARTMENT_ID`        ( Enter Compartment OCID )
- `OCI_AVAILABILITY_DOMAIN`   ( Enter Availability Domain like "hxIl:ME-JEDDAH-1-AD-1" )
- `OCI_SUBNET_ID`             ( Enter OCID of public subnet )
- `OCI_IMAGE_ID`              ( Enter Image OCID, you can get through Oracle CLI )
- `OCI_SSH_PUBLIC_KEY`        ( Generate a public and private key using **ssh-keygen -t rsa** cmd and Enter the content of Public key )
- `PRIVATE_KEY`               ( Enter content of Private key which is generated using **ssh-keygen -t rsa** cmd )
- `USER_OCI_PRIVATE_KEY`      ( Enter the content of Private Key you got from **API keys**)
- `OCI_CONFIG_CONTENT`        ( Enter $HOME/.oci/config File Content)



**********************************************************************

### Use these below Secret Variables as it is:

0| Secret Name                   | Terraform Variable              | Content                                  |
-|-------------------------------|----------------------------------|------------------------------------------|
1| `OCI_TENANCY_OCID`             | `TF_VAR_tenancy_ocid`            | Tenancy OCID                             |
2| `OCI_USER_OCID`                | `TF_VAR_user_ocid`               | User OCID                                |
3| `OCI_KEY_FINGERPRINT`          | `TF_VAR_fingerprint`             | Key Fingerprint                          |
4| `OCI_REGION`                   | `TF_VAR_region`                  | OCI Region (e.g., us-ashburn-1)          |
5| `OCI_COMPARTMENT_ID`           | `TF_VAR_compartment_id`          | Compartment OCID                         |
6| `OCI_AVAILABILITY_DOMAIN`      | `TF_VAR_availability_domain`     | Availability Domain (e.g., AD-1)         |
7| `OCI_SUBNET_ID`                | `TF_VAR_subnet_id`               | Subnet OCID                              |
8| `OCI_IMAGE_ID`                 | `TF_VAR_image_id`                | Image OCID                               |
9| `OCI_SSH_PUBLIC_KEY`           | `TF_VAR_ssh_public_key`          | Public SSH Key Content                   |
10| `PRIVATE_KEY`                  | `TF_VAR_ssh_private_key_path`    | SSH Private Key Content to access instance          |
11| `User_OCI_Private_Key`         | `TF_VAR_oci_private_key`         | User's OCI Private Key content      |
12| `OCI_Config_Content`           | `TF_VAR_oci_config_content`      | OCI Config File Content                  |


**********************************************************************


