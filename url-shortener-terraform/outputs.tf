output "api_gateway_base_url" {
  value = "https://${aws_api_gateway_rest_api.url_api.id}.execute-api.${var.aws_region}.amazonaws.com/prod"
}

output "s3_static_website_url" {
  value = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
}
