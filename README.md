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

This is a **basic example**. If you're interested in more comprehensive ECS customization, including:
- spot instances
- automatic draining of containers
- autoscaling
- modularization of components

See https://github.com/ericdahl/tf-ecs
