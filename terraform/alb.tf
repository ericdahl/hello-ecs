resource "aws_alb_target_group" "default" {
  name        = local.name
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  deregistration_delay = 0
}

resource "aws_alb" "default" {
  name            = local.name
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.alb.id]
}

resource "aws_alb_listener" "default" {
  load_balancer_arn = aws_alb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.default.id
    type             = "forward"
  }
}

resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id
  name   = "${local.name}-alb"
}

resource "aws_security_group_rule" "alb_ingress_http_all" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  to_port           = 80
  type              = "ingress"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress_all" {
  security_group_id        = aws_security_group.alb.id
  from_port                = 0
  protocol                 = "-1"
  to_port                  = 0
  type                     = "egress"
  source_security_group_id = aws_security_group.ecs_task.id
}