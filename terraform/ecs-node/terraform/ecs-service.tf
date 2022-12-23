# Providing a reference to our default VPC
resource "aws_default_vpc" "default-vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default-subnet-a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default-subnet-b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "default-subnet-c" {
  availability_zone = "us-east-1c"
}

resource "aws_security_group" "service-security-group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.alb-security-group.id]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_ecs_service" "node-app-service" {
  name            = "node-app-service"                        # Naming our first service
  cluster         = aws_ecs_cluster.node-app-cluster.id       # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.node-app-task.arn # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3                                         # Setting the number of containers we want deployed to 3
  security_groups = [aws_security_group.service-security-group.id]

  network_configuration {
    assign_public_ip = true # Providing our containers with public IPs

    subnets = [
      aws_default_subnet.default-subnet-a.id,
      aws_default_subnet.default-subnet-b.id,
      aws_default_subnet.default-subnet-c.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target-group.arn
    container_name   = aws_ecs_task_definition.node-app-task.family
    container_port   = 3000
  }
}