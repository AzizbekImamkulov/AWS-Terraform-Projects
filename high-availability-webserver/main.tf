# ------------------------------------------------------------------------------
# Provision a Highly Available Web Server in the Default VPC of Any Region
# 
# This setup includes:
#   - Security Group for the Web Server
#   - Launch Configuration with automatic AMI lookup
#   - Auto Scaling Group across 2 Availability Zones
#   - Classic Load Balancer in 2 Availability Zones
#
#   Created by Azizbek Imamkulov on April 16, 2025
# ------------------------------------------------------------------------------


provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "availability" {}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

#--------------------------------------------------------------------------------

resource "aws_security_group" "my_webserver" {
  name        = "Dynamic Security Group"
  description = "My Security Group"

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    name  = "Dynamic SecurityGroup"
    owner = "Azizbek Imamkulov"
  }
}

#--------------------------------------------------------------------------------

resource "aws_launch_template" "web" {
  name_prefix   = "WebServer-Highly-Available-LT-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  user_data              = filebase64("user_data.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name  = "WebServer"
      Owner = "Azizbek Imamkulov"
    }
  }
}

#--------------------------------------------------------------------------------

resource "aws_autoscaling_group" "web" {
  name_prefix      = "ASG-${aws_launch_template.web.name}"
  min_size         = 2
  max_size         = 2
  desired_capacity = 2
  vpc_zone_identifier = [
    aws_default_subnet.default_az0.id,
    aws_default_subnet.default_az1.id
  ]
  health_check_type = "ELB"
  load_balancers    = [aws_elb.web.name]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WebServer in ASG"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "Azizbek Imamkulov"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


#--------------------------------------------------------------------------------

resource "aws_elb" "web" {
  name               = "WebServer-Highly-Available-ELB"
  availability_zones = [data.aws_availability_zones.availability.names[0], data.aws_availability_zones.availability.names[1]]
  security_groups    = [aws_security_group.my_webserver.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  tags = {
    Name = "WebServer-Highly-Available-ELB"
  }
}

resource "aws_default_subnet" "default_az0" {
  availability_zone = data.aws_availability_zones.availability.names[0]
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.availability.names[1]
}



