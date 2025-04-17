# 🚀 Terraform Blue/Green Deployment with ALB and Auto Scaling Groups

This project provisions a high-availability web server architecture using Terraform. It leverages Amazon EC2 Auto Scaling Groups behind an Application Load Balancer across multiple availability zones.

## 🚀 Features

- ✅ Launches EC2 instances using the latest Amazon Linux 2 AMI
- ✅ Automatically scales to maintain 2 running instances
- ✅ Uses an Application Load Balancer (ALB) to distribute HTTP traffic
- ✅ Deploys across 2 Availability Zones for high availability
- ✅ Secures traffic with a Security Group allowing only HTTP/HTTPS

## 📦 Infrastructure Components

- **VPC & Subnets**: Uses AWS default VPC and creates subnets in 2 AZs
- **Security Group**: Allows inbound HTTP/HTTPS traffic and all outbound traffic
- **Launch Template**: Bootstraps instances using a `user_data.sh` script
- **Auto Scaling Group**: Ensures 2 instances are always running
- **Application Load Balancer**: Routes HTTP traffic to healthy EC2 instances
- **Target Group & Listener**: ALB forwards traffic to instances on port 80

## 📂 File Structure


## 🛠️ Prerequisites

- Terraform CLI installed
- AWS CLI configured with appropriate IAM permissions
- An S3 backend (optional, but recommended for state management)

## ▶️ How to Deploy

1. **Initialize Terraform:**

   ```bash
   terraform init
