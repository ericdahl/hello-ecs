resource "aws_ecs_cluster" "main" {
  name = "terraform_example_ecs_cluster"
}

data "template_file" "task_definition" {
  template = "${file("${path.module}/task-definition.json")}"

  vars {
//    image_url = "nginx:latest"
    image_url = "689973912904.dkr.ecr.us-west-2.amazonaws.com/hello-ecs:latest"
    container_name   = "nginx"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.app.name}"
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
  desired_count   = 3
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