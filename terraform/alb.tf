resource "aws_lb_target_group" "default" {
  name        = local.name
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  deregistration_delay = 0
}

resource "aws_lb" "default" {
  name            = local.name
  subnets         = aws_subnet.public[*].id
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.default.id
    type             = "forward"
  }
}

resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id
  name   = "${local.name}-alb"
}

resource "aws_vpc_security_group_ingress_rule" "alb_ingress_http_all" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_egress_http_app" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.ecs_task.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}
