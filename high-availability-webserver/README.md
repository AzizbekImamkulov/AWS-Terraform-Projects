# High-Availability Web Server on AWS with Terraform

This project provisions a **highly available web infrastructure** on AWS using Terraform, following a **Blue/Green deployment strategy**.

## ✅ Features

- 🔁 Blue/Green Deployments with Traffic Switching
- 🖥️ Auto Scaling Groups
- ⚖️ Application Load Balancer (ALB)
- 🌐 Dynamic Web Server with Ubuntu + Apache
- ☁️ Deployed into the Default VPC
- 🔐 Security Group with Open Web + SSH Access

---


---

## 🛠 Prerequisites

Before using this project, ensure you have:

- ✅ [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) v1.3 or newer
- ✅ [AWS CLI](https://aws.amazon.com/cli/) configured (`aws configure`)
- ✅ An AWS account with EC2, ELB, ASG, and IAM permissions

---

## 🚀 How to Deploy

### 1. Initialize the project
```bash
terraform init
terraform plan
terraform apply

If you make changes to user_data.sh (the startup script for your web server), you must force Terraform to recreate the Launch Template so the changes are picked up:

terraform apply -replace=aws_launch_template.web


Azizbek Imamkulov
🌍 Cloud Dev & Terraform enthusiast
📅 Created: April 2025

