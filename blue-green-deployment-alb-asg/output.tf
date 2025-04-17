output "web_loadbalancer_url" {
  value = aws_lb.web.dns_name
}
