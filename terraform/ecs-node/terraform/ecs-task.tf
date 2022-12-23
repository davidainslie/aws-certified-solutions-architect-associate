data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "node-app-task" {
  family = "node-app-task"
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode; this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn

  container_definitions = <<-EOT
  [{
    "name": "node-app-task",
    "image": "${aws_ecr_repository.backwards-ecr.repository_url}",
    "essential": true,
    "portMappings": [{
      "containerPort": 3000,
      "hostPort": 3000
    }],
    "memory": 512,
    "cpu": 256
  }]
  EOT
}