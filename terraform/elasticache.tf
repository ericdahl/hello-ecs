resource "aws_elasticache_cluster" "default" {
  cluster_id         = local.name
  engine             = "redis"
  node_type          = "cache.t4g.micro"
  port               = 6379
  num_cache_nodes    = 1
  subnet_group_name  = aws_elasticache_subnet_group.default.name
  security_group_ids = [aws_security_group.elasticache_sg.id]

  apply_immediately = true
}

resource "aws_elasticache_subnet_group" "default" {
  name       = local.name
  subnet_ids = aws_subnet.public.*.id
}

resource "aws_security_group" "elasticache_sg" {
  vpc_id = aws_vpc.main.id
  name   = "${local.name}-elasticache"
}

resource "aws_security_group_rule" "elasticache_ingresss_ecs" {
  security_group_id = aws_security_group.elasticache_sg.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 6379
  to_port   = 6379

  source_security_group_id = aws_security_group.ecs_task.id
  description              = "allows ECS Task to make connections to redis"
}

resource "aws_security_group_rule" "elasticache_ingress_admin" {
  security_group_id = aws_security_group.ecs_task.id

  from_port = 6379
  protocol  = "tcp"
  to_port   = 6379
  type      = "ingress"

  cidr_blocks = [var.admin_cidr_ingress]
  description = "allows admin to connect to redis"
}

