#!/bin/bash

API_URL=$(terraform output -raw api_gateway_base_url)
S3_URL=$(terraform output -raw s3_static_website_url)

if [[ -z "$API_URL" || -z "$S3_URL" ]]; then
  echo "❌ Не удалось получить значения из Terraform outputs."
  exit 1
fi

if [[ ! -d "frontend" ]]; then
  echo "❌ Директория 'frontend' не существует."
  exit 1
fi

cat <<EOF > frontend/.env
VITE_API_URL=$API_URL
VITE_S3_WEBSITE_URL=$S3_URL
EOF

echo "✅ .env файл успешно создан в frontend/.env"
