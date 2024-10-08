**********************************************************************
This file can create bastion host in oracle cloud with 1-CPU and 2-GB RAM, just provide secrets within github secrets.

**Username** = "ubuntu"

**Private key** = "create a public and private key using shh-keygen and place the public key within github secrets and use private key to access that instance"

**********************************************************************

### Enter these secrets into your github repo according to your requirements

![image](https://github.com/user-attachments/assets/12aaa549-c8cf-4c38-8d55-75bdae6ecde5)



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

7. **Update GitHub Actions Workflow**:
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
