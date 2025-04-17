# 🧩 Serverless URL Shortener (Terraform + AWS Free Tier)

This project is a URL shortener built using fully serverless AWS architecture — **100% within the Free Tier**. All infrastructure is defined using Terraform.

## ✨ Features

- Shorten long URLs
- Auto redirect from short URL
- Tracks click count
- Fully serverless (Lambda, API Gateway, DynamoDB, S3)

## 🧱 Architecture

- **API Gateway** – Exposes REST endpoints
- **Lambda** – Handles logic (Python)
- **DynamoDB** – Stores URL mappings
- **S3** – Hosts the frontend
- **CloudWatch** – Logs everything

## 🚀 How to Deploy

```bash
terraform init
terraform apply
