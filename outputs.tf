output "elb.address" {
  value = "${aws_elb.web.dns_name}"
}

output "ec2.public_ip" {
  value = ["${aws_instance.web.*.public_ip}"]
}