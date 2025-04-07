terraform {
  cloud {

    organization = "Henry-DevOps-Project"

    workspaces {
      name = "spring-petclinic-devops"
    }
  }
}
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "henry-devops-project.me"
  validation_method = "DNS"

  tags = {
    Name = "HenryDevOpsCert"
  }
}

resource "aws_lb" "spring_lb" {
  name               = "spring-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.spring_sg.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name = "SpringALB"
  }
}

resource "aws_lb_target_group" "spring_tg" {
  name     = "spring-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
    port                = "8080"
  }

  tags = {
    Name = "SpringTargetGroup"
  }
}

resource "aws_lb_target_group_attachment" "spring_target" {
  target_group_arn = aws_lb_target_group.spring_tg.arn
  target_id        = aws_instance.springboot.id
  port             = 8080
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.spring_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spring_tg.arn
  }
}

resource "aws_instance" "springboot" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 for us-east-1, true
  instance_type = "t2.micro"
  key_name      = var.key_name
  security_groups = [aws_security_group.spring_sg.name]
  monitoring = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              docker pull henry0810/spring-petclinic
              docker run -d -p 80:8080 henry0810/spring-petclinic
              EOF

  tags = {
    Name = "SpringBootApp"
  }
}

resource "aws_security_group" "spring_sg" {
  name        = "spring-app-sg"
  description = "Allow inbound traffic for HTTP, HTTPS, SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# CloudWatch CPU alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPUAlert"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when CPU usage exceeds 70%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.springboot.id
  }

  tags = {
    Name = "HighCPUAlert"
  }
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "devops-alerts"
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "munli2002@gmail.com"
}

