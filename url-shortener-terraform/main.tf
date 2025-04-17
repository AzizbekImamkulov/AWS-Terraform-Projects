#-----------------------------------------------
# My Terraform
#
# Serverless URL Shortener
#
# Description:
# A fully functional URL shortener where users can create short URLs that redirect to long URLs. It has a REST API, stores data, and provides analytics like click count. 
# Everything runs on the AWS Free Tier using serverless and cost-efficient services.
#
# Made by Azizbek Imamkulov
# April 1 2025
#-----------------------------------------------

provider "aws" {
  region = var.aws_region
}



resource "aws_dynamodb_table" "url_shortener" {
  name         = "url_shortener"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short_code"

  attribute {
    name = "short_code"
    type = "S"
  }

  tags = {
    Project     = "URLShortener"
    Environment = "dev"
  }
}


resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "lambda_dynamodb_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.url_shortener.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}


resource "aws_lambda_function" "create_short_url" {
  function_name    = "create_short_url"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "create_short_url.lambda_handler"
  runtime          = "python3.12"
  timeout          = 5
  filename         = "${path.module}/lambda/create_short_url.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/create_short_url.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.url_shortener.name
    }
  }
}


resource "aws_lambda_function" "redirect_url" {
  function_name    = "redirect_url"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "redirect_url.lambda_handler"
  runtime          = "python3.12"
  timeout          = 5
  filename         = "${path.module}/lambda/redirect_url.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/redirect_url.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.url_shortener.name
    }
  }
}


resource "aws_api_gateway_rest_api" "url_api" {
  name        = "url-shortener-api"
  description = "API Gateway for URL shortener"
}

resource "aws_api_gateway_resource" "create_path" {
  rest_api_id = aws_api_gateway_rest_api.url_api.id
  parent_id   = aws_api_gateway_rest_api.url_api.root_resource_id
  path_part   = "create"
}

resource "aws_api_gateway_resource" "shortcode_path" {
  rest_api_id = aws_api_gateway_rest_api.url_api.id
  parent_id   = aws_api_gateway_rest_api.url_api.root_resource_id
  path_part   = "{short_code}"
}

resource "aws_api_gateway_method" "create_method" {
  rest_api_id   = aws_api_gateway_rest_api.url_api.id
  resource_id   = aws_api_gateway_resource.create_path.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "redirect_method" {
  rest_api_id   = aws_api_gateway_rest_api.url_api.id
  resource_id   = aws_api_gateway_resource.shortcode_path.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_integration" {
  rest_api_id             = aws_api_gateway_rest_api.url_api.id
  resource_id             = aws_api_gateway_resource.create_path.id
  http_method             = aws_api_gateway_method.create_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_short_url.invoke_arn
}

resource "aws_api_gateway_integration" "redirect_integration" {
  rest_api_id             = aws_api_gateway_rest_api.url_api.id
  resource_id             = aws_api_gateway_resource.shortcode_path.id
  http_method             = aws_api_gateway_method.redirect_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.redirect_url.invoke_arn
}

resource "aws_lambda_permission" "api_gw_create" {
  statement_id  = "AllowAPIGatewayInvokeCreate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_short_url.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.url_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gw_redirect" {
  statement_id  = "AllowAPIGatewayInvokeRedirect"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect_url.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.url_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "url_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.url_api.id

  depends_on = [
    aws_api_gateway_integration.create_integration,
    aws_api_gateway_integration.redirect_integration
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.create_path.path_part,
      aws_api_gateway_resource.shortcode_path.path_part,
      aws_api_gateway_method.create_method.http_method,
      aws_api_gateway_method.redirect_method.http_method
    ]))
  }
}


resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.url_api.id
  deployment_id = aws_api_gateway_deployment.url_api_deployment.id
}


resource "aws_s3_bucket" "frontend_bucket" {
  bucket        = "url-shortener-frontend-${random_id.bucket_id.hex}"
  force_destroy = true

  tags = {
    Name = "Frontend Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = ["s3:GetObject"],
      Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
    }]
  })
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = "index.html"
  source       = "${path.module}/frontend/index.html"
  content_type = "text/html"
}
