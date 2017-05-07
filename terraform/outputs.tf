output "instance_security_group" {
  value = "${aws_security_group.instance_sg.id}"
}

output "launch_configuration" {
  value = "${aws_launch_configuration.app.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.app.id}"
}

output "elb_hostname" {
  value = "${aws_alb.main.dns_name}"
}

output "vpc_subnets" {
  value = ["${aws_subnet.main.*.cidr_block}"]
}

output "elasticache_node" {
  value = ["${aws_elasticache_cluster.default.cache_nodes.0.address}"]
}