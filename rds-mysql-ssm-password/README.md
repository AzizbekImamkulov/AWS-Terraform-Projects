# Terraform AWS RDS MySQL

This Terraform project provisions an **Amazon RDS MySQL** instance with a **secure, randomly generated password** stored in **AWS Systems Manager Parameter Store (SSM)**.

## 🔧 Features

- ✅ Creates a **random, secure password** using `random_string`
- 🔐 Stores the password as a `SecureString` in **SSM Parameter Store**
- 🛠 Provisions an **RDS MySQL 8.0** instance (`db.t3.micro`)
- 📦 Password is retrieved from SSM using Terraform `data` block
- ⚠️ Outputs the password securely (marked as `sensitive`)

---

## 📁 Project Structure


---

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads)
- AWS CLI configured (`aws configure`)
- IAM permissions for RDS, SSM Parameter Store, EC2 (for networking), etc.

### Deploy

```bash
terraform init
terraform apply
terraform output rds_password
terraform output --raw rds_password
terraform destroy
