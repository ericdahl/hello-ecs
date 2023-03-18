resource "aws_ecs_cluster" "default" {
  name = local.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}