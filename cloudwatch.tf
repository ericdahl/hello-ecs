resource "aws_cloudwatch_log_group" "ecs" {
  name = "tf-ecs-group/ecs-agent"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "app" {
  name = "tf-ecs-group/app-nginx"
  retention_in_days = 3
}
