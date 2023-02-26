output "alb_hostname" {
  value = aws_alb.default.dns_name
}

output "vpc_subnets" {
  value = [aws_subnet.public.*.cidr_block]
}
