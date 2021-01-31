resource "aws_cloudwatch_log_group" "app" {
  name              = "/hello-ecs/app"
  retention_in_days = 3
}

