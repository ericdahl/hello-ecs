resource "aws_elasticache_cluster" "default" {
  cluster_id         = var.name
  engine             = "redis"
  node_type          = "cache.t3.micro"
  port               = 6379
  num_cache_nodes    = 1
  subnet_group_name  = aws_elasticache_subnet_group.default.name
  security_group_ids = [aws_security_group.elasticache_sg.id]
}

resource "aws_elasticache_subnet_group" "default" {
  name       = var.name
  subnet_ids = aws_subnet.public.*.id
}

resource "aws_security_group" "elasticache_sg" {
  vpc_id = aws_vpc.main.id
  name   = "${var.name}-elasticache"

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"

    security_groups = [
      aws_security_group.ecs_task.id
    ]
    description = "allows ECS Task to make connections to redis"
  }
}

