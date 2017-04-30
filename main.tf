provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name = "terraform vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "elb" {
  name = "terraform_elb"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_security_group" "default" {
  name = "terraform_sg"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "terraform-example-elb"

  subnets = [
    "${aws_subnet.default.id}"]
  security_groups = [
    "${aws_security_group.elb.id}"]
  instances = [
    "${aws_instance.web.*.id}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    target = "HTTP:80/?lb_check"
    interval = 10
    timeout = 3
    healthy_threshold = 3
    unhealthy_threshold = 3
  }
}
//
//  access_logs {
//    bucket        = "${aws_s3_bucket.default.id}"
//    bucket_prefix = "logs"
//    interval      = 5
//  }
//}
//
//resource "aws_s3_bucket" "default" {
//  bucket = "terraform-elb-logs"
//
//}


# Simply specify the family to find the latest ACTIVE revision in that family.
//data "aws_ecs_task_definition" "mongo" {
//  task_definition = "${aws_ecs_task_definition.mongo.family}"
//}

resource "aws_ecs_cluster" "default" {
  name = "terraform-ecs-cluster"
}
//
//resource "aws_ecs_task_definition" "mongo" {
//  family = "mongodb"
//
//  container_definitions = <<DEFINITION
//[
//  {
//    "cpu": 128,
//    "environment": [{
//      "name": "SECRET",
//      "value": "KEY"
//    }],
//    "essential": true,
//    "image": "mongo:latest",
//    "memory": 128,
//    "memoryReservation": 64,
//    "name": "mongodb"
//  }
//]
//DEFINITION
//}
//
//resource "aws_ecs_service" "mongo" {
//  name          = "mongo"
//  cluster       = "${aws_ecs_cluster.foo.id}"
//  desired_count = 2
//
//  # Track the latest ACTIVE revision
//  task_definition = "${aws_ecs_task_definition.mongo.family}:${max("${aws_ecs_task_definition.mongo.revision}", "${data.aws_ecs_task_definition.mongo.revision}")}"
//}


resource "aws_instance" "web" {
  ami = "ami-d9a33ab9"
  instance_type = "t2.micro"
  key_name = "ec2-temp-2017-04-21"
  subnet_id = "${aws_subnet.default.id}"

  connection {
    user = "ec2-user"
  }

  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  count = 2

}
