# Application Load Balancer

resource "aws_lb_target_group" "tg" {
  name        = "TargetGroup"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_alb_target_group_attachment" "tg-attachment" {
  count            = length(aws_instance.ec2-public.*.id)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = element(aws_instance.ec2-public.*.id, count.index)
}

resource "aws_lb" "lb" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security-group-public.id]
  subnets            = aws_subnet.public-subnet.*.id
}

resource "aws_lb_listener" "front-end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }

  /*
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  */
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.front-end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    path_pattern {
      values = ["/var/www/html/index.html"]
    }
  }
}