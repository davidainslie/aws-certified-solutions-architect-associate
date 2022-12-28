# Creating a security group for the load balancer:
resource "aws_security_group" "alb-security-group" {
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_alb" "node-app-alb" {
  name = "node-app-alb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb-security-group.id]

  subnets = [
    aws_default_subnet.default-subnet-a.id,
    aws_default_subnet.default-subnet-b.id,
    aws_default_subnet.default-subnet-c.id
  ]
}

resource "aws_lb_target_group" "target-group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default-vpc.id

  health_check {
    matcher = "200,301,302"
    path = "/"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.node-app-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

output "dns" {
  value = aws_alb.node-app-alb.dns_name
}