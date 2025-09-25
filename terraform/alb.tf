data "aws_vpc" "innovart-vpc" {
  id = "vpc-007d0bab3d3943c89"
}

data "aws_subnet" "pub-subnet" {
  id = "subnet-01b391f3db5c23abd"
}

data "aws_subnet" "priv-subnet" {
  id = "subnet-01f1ee4bdcbd257d1"
}

resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.innovart-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb" "app-lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [data.aws_subnet.pub-subnet.id, data.aws_subnet.priv-subnet.id]

  enable_deletion_protection = true

  tags = {
    Name = "app-lb"
  }
}

resource "aws_lb_target_group" "app-tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.innovart-vpc.id

  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "app-tg"
  }
}

resource "aws_lb_listener" "app-listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.app-lb.dns_name
}

output "alb_arn" {
  value = aws_lb.app-lb.arn
}

