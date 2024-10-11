[Self Hosted Runner Details](https://github.com/Umair7865/oracle_oci-cli_and_terraform?tab=readme-ov-file#step-by-step-guide-to-use-oracle-cloud-vm-as-github-actions-runner)
**********************************************************************
This file can create bastion host in oracle cloud with 1-CPU and 2-GB RAM, just provide secrets within github secrets.

**Username** = "ubuntu"

**Private key** = "create a public and private key using shh-keygen and place the public key within github secrets and use private key to access that instance"

## For Creating Bastion-host using github actions:
please make sure the below priority things according to your environment
- OCI_AVAILABILITY_DOMAIN   ( Enter Availability Domain like "hxIl:ME-JEDDAH-1-AD-1" )
- OCI_COMPARTMENT_ID        ( Enter Compartment OCID )
- OCI_CONFIG_CONTENT        ( Enter $HOME/.oci/config File Content)
- OCI_IMAGE_ID              ( Enter Image OCID, you can get through Oracle CLI )
- OCI_KEY_FINGERPRINT       ( Enter Fingerprint from go to **My profile** _(top right corner)_ --- go to **API keys** )
- OCI_PRIVATE_KEY           ( Enter Path to the SSH private key used for remote access )
- OCI_PRIVATE_KEY_PATH
- OCI_REGION                ( Enter region like "me-jeddah-1" )
- OCI_SSH_PUBLIC_KEY        ( Generate a public and private key using **ssh-keygen -t rsa** cmd and Enter the content of Public key )
- OCI_SUBNET_ID             ( Enter OCID of public subnet )
- OCI_TENANCY_OCID          ( Enter tenancy OCID )
- OCI_USER_OCID             ( Enter OCID of user )
- PRIVATE_KEY               
- USER_OCI_PRIVATE_KEY      ( Enter the content of Private Key you got from **API keys**)

  

**********************************************************************

### Enter these secrets into your github repo according to your requirements

![image](https://github.com/user-attachments/assets/05f64597-64e4-4799-87d3-392a4f5dc0a3)



**********************************************************************


Creating a self-hosted GitHub Actions runner allows you to customize your CI/CD workflow to run on your infrastructure. Given your setup with a mix of cloud and on-premises environments, you can configure a GitHub Actions runner on one of your servers.

Here are the steps to set up your own GitHub Actions runner:

### Step-by-Step Guide

1. **Create a GitHub Personal Access Token**:
   - Go to your GitHub account settings, select **Developer settings > Personal access tokens**.
   - Generate a token with **repo** and **admin:org** permissions, as it will be required to register the runner.

2. **Choose a Machine**:
   - Use one of your on-premises or cloud servers to host the runner. Ensure it meets the required specs (CPU, memory, etc.) for running the jobs.

3. **Navigate to GitHub Repository**:
   - Go to your GitHub repository.
   - Select **Settings > Actions > Runners**.
   - Click on **Add runner**.

4. **Download and Install the Runner**:
   - GitHub will provide you with a set of commands to download and configure the runner. Here’s a typical example:

     ```sh
     # Create a directory
     mkdir actions-runner && cd actions-runner

     # Download the latest runner package
     curl -o actions-runner-linux-x64-2.308.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.308.0/actions-runner-linux-x64-2.308.0.tar.gz

     # Extract the installer
     tar xzf ./actions-runner-linux-x64-2.308.0.tar.gz
     ```

5. **Configure the Runner**:
   - Run the configuration script to link this runner with your repository. You’ll need to use the URL and token provided by GitHub in the setup instructions.

     ```sh
     # Replace REPO_URL and TOKEN with actual values provided by GitHub
     ./config.sh --url https://github.com/owner/repository --token YOUR_TOKEN
     ```

   - You can also specify labels during this step. Labels can help run jobs on specific runners (e.g., `on-prem`, `cloud`, etc.):

     ```sh
     ./config.sh --url https://github.com/owner/repository --token YOUR_TOKEN --labels my-runner
     ```

6. **Install Runner as a Service**:
   - Once configured, you can install the runner as a service to ensure it runs automatically.

     ```sh
     sudo ./svc.sh install
     sudo ./svc.sh start
     ```

7. **Add or Modify Labels**
   - If there is a label mismatch, reconfigure the runner with the correct labels.
   - To do so, SSH into your VM and navigate to the `actions-runner` directory:

     ```sh
     cd ~/actions-runner
     ./config.sh remove  # To remove the existing configuration
     ```

   - Then, configure the runner again with the correct URL, token, and labels:

     ```sh
     ./config.sh --url https://github.com/owner/repository --token YOUR_TOKEN --labels my-runner
     ```

8. **Update GitHub Actions Workflow**:
   - To use the self-hosted runner, update your GitHub Actions workflow to target the runner using its label.

     ```yaml
     name: CI Workflow

     on: [push, pull_request]

     jobs:
       build:
         runs-on: self-hosted
         steps:
           - name: Checkout code
             uses: actions/checkout@v3

           - name: Set up Node.js
             uses: actions/setup-node@v3
             with:
               node-version: '16'

           - name: Install dependencies
             run: npm install

           - name: Run build
             run: npm run build
     ```

### Example Scenario: On-Premises Runner
Given your setup, you could create a runner on one of your on-premises servers.

1. **Configure Networking**:
   Ensure the machine has access to the internet for downloading dependencies and interacting with GitHub APIs. You may need to configure your firewall to allow specific traffic.

2. **DaemonSet for Cloud Setup**:
   In your cloud Kubernetes environment, you can use a DaemonSet to deploy runners across nodes. Here's an example YAML for deploying GitHub Actions runners using a DaemonSet in Kubernetes:

   ```yaml
   apiVersion: apps/v1
   kind: DaemonSet
   metadata:
     name: github-runner
   spec:
     selector:
       matchLabels:
         app: github-runner
     template:
       metadata:
         labels:
           app: github-runner
       spec:
         containers:
           - name: runner
             image: my-github-runner-image:latest
             env:
               - name: REPO_URL
                 value: https://github.com/owner/repository
               - name: RUNNER_TOKEN
                 valueFrom:
                   secretKeyRef:
                     name: runner-secret
                     key: token
             volumeMounts:
               - name: runner-config
                 mountPath: /runner/config
         volumes:
           - name: runner-config
             emptyDir: {}
   ```

   This way, you ensure all cloud nodes have a runner, similar to your EDR DaemonSet setup.

### Tips for Your Setup
1. **Security Considerations**:
   - Since your infrastructure involves sensitive financial data and SAMA compliance, you need to carefully monitor access to the runner.
   - Use a firewall to restrict communication, and only allow access to specific IPs and GitHub endpoints.

2. **Scaling and Management**:
   - Label the runners appropriately based on the environment (`cloud`, `on-prem`) so you can target jobs accordingly.
   - Monitor the runners' performance, especially when using them for heavy CI/CD workloads.

### Summary
- Use the on-premises or cloud machine to host the runner.
- Follow GitHub's instructions for downloading, configuring, and running the runner.
- Deploy it as a service or use DaemonSets for Kubernetes.
- Update your workflow files to run jobs on `self-hosted` runners.

This setup helps you integrate your hybrid infrastructure into the CI/CD pipeline, allowing flexibility and leveraging your existing resources. If you have specific requirements for a particular infrastructure part, let me know, and we can tweak the setup accordingly.


**********************************************************************


To use your Oracle Cloud VM as a GitHub Actions runner, you can follow a similar process as before. The key is to configure the runner to run on your Oracle Cloud VM to meet your security requirements. Below, I’ll walk you through the process:

### Step-by-Step Guide to Use Oracle Cloud VM as GitHub Actions Runner

1. **Access Your Oracle Cloud VM**:
   - SSH into the VM you want to use as the GitHub Actions runner.

   ```sh
   ssh opc@<VM_IP_ADDRESS>
   ```

2. **Install Dependencies**:
   - Ensure your Oracle Cloud VM has the required dependencies for GitHub Actions runner.
     - Install `curl`:

       ```sh
       sudo apt-get update
       sudo apt-get install -y curl
       ```

3. **Download and Install GitHub Actions Runner**:
   - Create a directory for the runner:

     ```sh
     mkdir actions-runner && cd actions-runner
     ```

   - Download the GitHub Actions runner software:

     ```sh
     curl -o actions-runner-linux-x64-2.308.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.308.0/actions-runner-linux-x64-2.308.0.tar.gz
     ```

   - Extract the installer:

     ```sh
     tar xzf ./actions-runner-linux-x64-2.308.0.tar.gz
     ```

4. **Configure the Runner**:
   - Obtain the runner registration token:
     - Go to your GitHub repository **Settings > Actions > Runners** and click **Add Runner**.
     - You will see a token along with instructions.

   - Register your VM as a GitHub Actions runner by running:

     ```sh
     # Replace REPO_URL and TOKEN with actual values
     ./config.sh --url https://github.com/owner/repository --token YOUR_TOKEN
     ```

   - You can specify labels during the configuration step to target jobs specifically for this runner:

     ```sh
     ./config.sh --url https://github.com/owner/repository --token YOUR_TOKEN --labels oracle-vm-runner
     ```

5. **Run the Runner**:
   - Start the runner:

     ```sh
     ./run.sh
     ```

   - To ensure the runner automatically starts when your VM reboots, install it as a service:

     ```sh
     sudo ./svc.sh install
     sudo ./svc.sh start
     ```

6. **Update GitHub Actions Workflow**:
   - Update your GitHub Actions workflow to use this specific runner by referencing the label (`oracle-vm-runner`):

     ```yaml
     name: Oracle Cloud VM CI Workflow

     on: [push, pull_request]

     jobs:
       build:
         runs-on: self-hosted
         labels: [oracle-vm-runner]
         steps:
           - name: Checkout code
             uses: actions/checkout@v3

           - name: Set up Node.js
             uses: actions/setup-node@v3
             with:
               node-version: '16'

           - name: Install dependencies
             run: npm install

           - name: Run build
             run: npm run build
     ```

### Security Considerations
1. **Networking**:
   - Ensure that your Oracle Cloud VM is secured using Oracle's network security groups (NSGs) or firewall rules. Only allow necessary traffic and restrict inbound connections to trusted IP addresses.
   
2. **Access Control**:
   - Use an IAM policy in Oracle Cloud to restrict access to this VM.
   - Limit the permissions of the GitHub runner token. Only provide `repo` and `workflow` scopes to minimize the attack surface.

3. **Monitoring**:
   - Set up monitoring and alerts in Oracle Cloud to track the runner's activity. You can also use SIEM tools like Wazuh for centralized monitoring (as per your SOC requirements).

### Summary
- Set up your Oracle Cloud VM as a GitHub Actions self-hosted runner.
- Register the runner using GitHub's token and instructions.
- Use labels to direct workflows to your Oracle Cloud VM.
- Secure and monitor the VM to align with your security standards.

This approach gives you more control over the environment, ensuring compliance and security for your CI/CD operations. Let me know if you need more details on setting up monitoring or securing the runner further.

**********************************************************************
