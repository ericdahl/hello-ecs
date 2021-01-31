resource "aws_ecs_cluster" "default" {
  name = var.name
}

resource "aws_ecs_task_definition" "default" {
  family                = var.name
  container_definitions = templatefile("${path.module}/templates/tasks/app.json", { redis_host = aws_elasticache_cluster.default.cache_nodes[0].address })

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
}

resource "aws_ecs_service" "default" {
  name            = var.name
  cluster         = aws_ecs_cluster.default.name
  task_definition = aws_ecs_task_definition.default.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = aws_subnet.public.*.id

    security_groups = [
      aws_security_group.ecs_task.id
    ]
    assign_public_ip = true # not ideal, but to help avoid paying for a NAT gateway
  }

  depends_on = [aws_alb.default]

  load_balancer {
    target_group_arn = aws_alb_target_group.default.arn
    container_name   = "hello-ecs"
    container_port   = 8080
  }
}

resource "aws_security_group" "ecs_task" {

  name   = "${var.name}-ecs-task"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 8080
    protocol        = "tcp"
    to_port         = 8080
    security_groups = [aws_security_group.alb.id]
    description     = "allows ALB to make requests to ECS Task"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_task_execution" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution.arn
}