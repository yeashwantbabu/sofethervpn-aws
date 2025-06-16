# 🚀 SoftEther VPN EC2 Deployment via AWS CloudFormation

This project provides an automated solution to deploy a **SoftEther VPN** server on an **Amazon EC2 instance** using **AWS CloudFormation**. The deployment includes a static **Elastic IP**, optional **AWS Systems Manager (SSM)** integration, and essential networking and security setup.

---

## 📄 Overview

- **CloudFormation Template**  
  Provisions an EC2 instance with SoftEther VPN installed via EC2 UserData. It also configures networking (VPC/Subnet), security groups, IAM roles, and associates an Elastic IP.

- **Shell Deployment Script (`deploy.sh`)**  
  Automatically fetches the latest Amazon Linux 2 AMI ID, sets up required parameters, and launches the CloudFormation stack.

---

## ✅ Prerequisites

Ensure you have the following before deploying:

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed and configured (`aws configure`)
2. An existing EC2 **Key Pair** (for SSH access)
3. **IAM permissions** to
    - Create CloudFormation stacks
    - Launch EC2 instances
    - Create IAM roles and instance profiles
    - Allocate and associate Elastic IPs
4. **public VPC and Subnet** with internet access

---
## AWS CLI Configuration
- To interact with AWS services via the CLI, you need an Access Key ID and Secret Access Key associated with an IAM user.
- create an IAM user and access keys:
    - Log in to the AWS Management Console
    - Navigate to IAM > Users
    - Click Add user
    - Provide a user name (e.g., cli-user)
    - Select Programmatic access
    - Click Next and attach the appropriate permissions (e.g., AdministratorAccess or scoped permissions)
    - Complete the user creation and download or copy the Access Key ID and Secret Access Key

⚠️ Never share your secret access key. Store it securely.

---

## Configure AWS CLI:

- Once you have your access keys:
    - aws configure

- You'll be prompted to enter:
    - AWS Access Key ID
    - AWS Secret Access Key
    - Default region name (e.g., us-east-1)
    - Default output format


## 🗂 File Structure
- Softether-VPN-CF-Temp.yaml # CloudFormation Template
- deploy.sh # Deployment Script


---

## ⚙️ Parameters

| Parameter        | Description                                       | 
|------------------|---------------------------------------------------|
| `InstanceName`   | Name tag for the EC2 instance                     | 
| `InstanceType`   | EC2 instance type                                 |
| `KeyName`        | Your existing EC2 key pair name                   | 
| `LatestAmiId`    | Amazon Linux 2 AMI ID (auto-filled via SSM)       | 
| `VpcId`          | Your public VPC ID                                | 
| `SubnetId`       | Your public subnet ID                             | 
| `AttachSSMRole`  | Attach IAM role for SSM (true or false)           | 
| `Environment`    | Tag for environment                               | 
| `CreatedBy`      | Tag for owner/creator                             | 
| `ProjectName`    | Tag for project name                              | 

---

## 🚀 Deployment Steps

1. **Clone the Repository**
    - ```bash
    - git clone git@bitbucket.org:futuralis/s-0071066-infra.git
    - cd s-0071066-infra
2. **Review and Update Parameters** 
    - Open deploy.sh and adjust the following variables as needed: 
    - STACK_NAME="softether-vpn-stack-1" 
    - KEY_NAME="your-keypair-name" 
    - VPC_ID="your-vpc-id" 
    - SUBNET_ID="your-public-subnet-id" 
3. **Run the Deployment Script** 
    - Make the script executable and run: 
    - chmod +x deploy.sh 
    - ./deploy.sh

---

## The script will:

1. Automatically find the latest Amazon Linux 2 AMI
2. Deploy the CloudFormation stack
3. Wait until the stack is successfully created
4. Display stack outputs (Elastic IP, SSH/SSM command, etc.)