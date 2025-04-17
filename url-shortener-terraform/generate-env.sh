#!/bin/bash

API_URL=$(terraform output -raw api_gateway_base_url)
S3_URL=$(terraform output -raw s3_static_website_url)

cat <<EOF > frontend/.env
VITE_API_URL=$API_URL
VITE_S3_WEBSITE_URL=$S3_URL
EOF

echo "✅ .env file created in frontend/.env"
