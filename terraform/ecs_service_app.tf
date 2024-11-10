resource "aws_ecs_task_definition" "default" {
  family = local.name
  container_definitions = templatefile("${path.module}/templates/tasks/app.json", {
    redis_host   = aws_elasticache_cluster.default.cache_nodes[0].address,
    cw_log_group = aws_cloudwatch_log_group.app.name
  })

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
}

resource "aws_ecs_service" "default" {
  name            = local.name
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

  # java app can take ~100 seconds to start up with
  # current memory settings
  # 2023-03-05 17:44:11.314  INFO 7 --- [           main] example.App                              : Started App in 88.608 seconds (JVM running for 93.593)
  health_check_grace_period_seconds = 300

  load_balancer {
    target_group_arn = aws_alb_target_group.default.arn
    container_name   = "hello-ecs"
    container_port   = 8080
  }
}

resource "aws_security_group" "ecs_task" {
  name   = "${local.name}-ecs-task"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ecs_task_ingress_alb" {
  security_group_id = aws_security_group.ecs_task.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 8080
  to_port   = 8080

  source_security_group_id = aws_security_group.alb.id

  description = "allows ALB to make requests to ECS Task"
}

resource "aws_security_group_rule" "ecs_task_ingress_admin" {
  security_group_id = aws_security_group.ecs_task.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 8080
  to_port   = 8080

  cidr_blocks = [var.admin_cidr_ingress]

  description = "allow connections to ECS tasks from admin cidr for debugging"
}



resource "aws_security_group_rule" "ecs_task_egress_all" {
  security_group_id = aws_security_group.ecs_task.id

  type     = "egress"
  protocol = "-1"

  from_port = 0
  to_port   = 0

  cidr_blocks = ["0.0.0.0/0"]
  description = "allows ECS task to make egress calls"
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/hello-ecs/app"
  retention_in_days = 3
}

resource "aws_appautoscaling_target" "app" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.default.name}/${aws_ecs_service.default.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "app" {
  name               = "app"
  resource_id        = aws_appautoscaling_target.app.resource_id
  scalable_dimension = aws_appautoscaling_target.app.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app.service_namespace

  policy_type = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    target_value = 25

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_alb.default.arn_suffix}/${aws_alb_target_group.default.arn_suffix}"
    }
  }
}
