# 🌐 Terraform AWS Infrastructure

Welcome! This is a modular Terraform setup for creating an AWS Virtual Private Cloud (VPC) and securing your web server infrastructure.

---

## 📁 Project Structure

```plaintext
terraform-aws-infra/
├── network/         # VPC & Internet Gateway
├── servers/         # Security Group for Web Servers
└── README.md

🧠 Architecture Overview

       +--------------------------+
       |      Internet (0.0.0.0)  |
       +------------+-------------+
                    |
                    v
          +-------------------+
          | Internet Gateway  |
          +--------+----------+
                   |
                   v
          +-------------------+
          |      VPC          | 10.0.0.0/16
          |-------------------|
          |  +-------------+  |
          |  | Security SG |<--------------------+
          |  |  (Web/SSH)  |                     |
          |  +-------------+                     |
          +-------------------+                 [ Access Control ]

☁️ Remote Backend (S3)
Both modules use the same S3 bucket for state management:


Module	S3 State Key
network	dev/network/terraform.tfstate
servers	dev/servers/terraform.tfstate
🔐 Make sure the bucket azizbek-imamkulov-terraform-state exists in us-east-1.

🚀 Deployment Steps
1. Deploy Network Resources
cd network/
terraform init
terraform apply
2. Deploy Server Security Group
cd ../servers/
terraform init
terraform apply

📦 Outputs
network/

Output	Description
vpc_id	ID of created VPC
vpc_cidr	CIDR block of the VPC

servers/

Output	Description
webserver_sg.id	Webserver security group ID

👨‍💻 Author
Azizbek Imamkulov
AWS Terraform enthusiast | Cloud builder

📝 Notes
Expand the project by adding subnets, NAT Gateways, EC2 instances, Load Balancers, etc.

This structure is great for real-world deployments using Terraform Remote State.

```
