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
  description = "controls access to the application ELB"

  vpc_id = aws_vpc.main.id
  name   = "${local.name}-alb"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

