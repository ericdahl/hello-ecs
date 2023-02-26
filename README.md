# hello-ecs

Demo using
- AWS (via terraform)
    - ECS
    - ALB
    - CloudWatch logs via docker plugin
    - ElastiCache redis
- spring-boot web app
    - connected to ElastiCache

It also creates the base infrastructure (VPC, IAM) so that it's completely self-contained. If you
already have these things, you could remove that config.

This is not meant for production. For speed of deployments and lower costs, resources are deployed
into public subnets. Security Groups are in place to lock down access, but ideally the resources
are deployed into private subnets with a NAT Gateway

This is a **basic example**. If you're interested in more comprehensive ECS customization, including:
- spot instances
- automatic draining of containers
- autoscaling
- modularization of components

See https://github.com/ericdahl/tf-ecs
