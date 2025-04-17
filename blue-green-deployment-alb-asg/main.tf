provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Owner     = "Azizbek Imamkulov"
      CreatedBy = "Terraform"
    }
  }
}
#-----------------------------------------------------------------

# Get all available availability zones in the region
data "aws_availability_zones" "available" {}

# Fetch the latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
#-----------------------------------------------------------------

# Create the default VPC
resource "aws_default_vpc" "default" {}

# Create default subnet in the first availability zone
resource "aws_default_subnet" "az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

# Create default subnet in the second availability zone
resource "aws_default_subnet" "az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}
#-----------------------------------------------------------------

resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = aws_default_vpc.default.id

  # Allow inbound HTTP and HTTPS
  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web Security Group"
  }
}
#-----------------------------------------------------------------

resource "aws_launch_template" "web" {
  name_prefix   = "webserver-HA-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data = filebase64("${path.module}/user_data.sh")
}
#-----------------------------------------------------------------

locals {
  safe_timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
}

resource "aws_autoscaling_group" "web" {
  name              = "webserver-ha-asg-${local.safe_timestamp}"
  min_size          = 2
  max_size          = 2
  desired_capacity  = 2
  min_elb_capacity  = 2
  health_check_type = "ELB"
  vpc_zone_identifier = [
    aws_default_subnet.az1.id,
    aws_default_subnet.az2.id
  ]
  target_group_arns = [aws_lb_target_group.web.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG v${aws_launch_template.web.latest_version}"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
#-----------------------------------------------------------------

resource "aws_lb" "web" {
  name               = "webserver-HA-ALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets = [
    aws_default_subnet.az1.id,
    aws_default_subnet.az2.id
  ]
}

resource "aws_lb_target_group" "web" {
  name                 = "webserver-HA-TG"
  vpc_id               = aws_default_vpc.default.id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 10
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}


