resource "aws_ecs_cluster" "main" {
  name = "terraform_example_ecs_cluster"
}

data "template_file" "task_definition" {
  template = "${file("${path.module}/templates/tasks/app.json")}"

  vars {
    image_url = "689973912904.dkr.ecr.us-west-2.amazonaws.com/hello-ecs:20170508-0405-c7d56e7"
    container_name   = "nginx"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.app.name}"
//    redis_host       = "${aws_elasticache_cluster.default.cache_nodes.0.address}"
    redis_host       = "localhost"
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family                = "tf_example_nginx_td"
  container_definitions = "${data.template_file.task_definition.rendered}"
}

resource "aws_ecs_service" "test" {
  name            = "tf-example-ecs-nginx"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.nginx.arn}"
  desired_count   = 2
  iam_role        = "${aws_iam_role.ecs_service.name}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.test.id}"
    container_name   = "nginx"
    container_port   = "8080"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.front_end",
  ]
}