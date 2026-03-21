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

## Prerequisites

You'll need the following installed locally:

- Docker
- Java 25 (if you want to build/test without Docker)
- Maven 3.9+
- Terraform
- AWS CLI

You'll also need:

- an AWS account
- AWS credentials configured for the AWS CLI
- permission to create ECS, ALB, IAM, VPC, CloudWatch Logs, and ElastiCache resources
- a Docker Hub account that can push the `ericdahl/hello-ecs` image, or a corresponding image/tag update in Terraform

## Building and testing locally

The application source lives under `app/`.

### Build and tag the Docker image

From the `app/` directory:

```bash
make build
```

This will:
- build the image as `hello-ecs:<git-sha>`
- tag it as `ericdahl/hello-ecs:latest`
- tag it as `ericdahl/hello-ecs:<git-sha>`

### Push the image

```bash
cd app
make deploy
```

This runs the build and then pushes `ericdahl/hello-ecs:<git-sha>` to Docker Hub.

### Build without Docker

If you just want to verify the Java app builds:

```bash
cd app
mvn clean package
```

### Run locally

You can also run the packaged app locally:

```bash
cd app
mvn spring-boot:run
```

Note: this project is designed to talk to Redis in AWS when deployed. Running locally may require additional environment/config setup depending on what you want to test.

## Deploying to AWS

Terraform code lives under `terraform/`.

### 1. Configure AWS credentials

Make sure the AWS CLI is authenticated, for example:

```bash
aws sts get-caller-identity
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

### 3. Review the deployment plan

At minimum, provide an admin CIDR block for debug access:

```bash
terraform plan -var 'admin_cidr_ingress=YOUR.IP.ADDR.ESS/32'
```

Optional variables:
- `aws_region` (default: `us-west-2`)
- `az_count` (default: `2`)

Example:

```bash
terraform plan \
  -var 'admin_cidr_ingress=YOUR.IP.ADDR.ESS/32' \
  -var 'aws_region=us-west-2' \
  -var 'az_count=2'
```

### 4. Apply

```bash
terraform apply -var 'admin_cidr_ingress=YOUR.IP.ADDR.ESS/32'
```

When apply completes, Terraform will output the ALB URL.

## Testing the deployment

After `terraform apply`, fetch the output URL:

```bash
cd terraform
terraform output alb
```

Then hit the service in a browser or with curl:

```bash
curl "$(terraform output -raw alb)"
```

Depending on application behavior, you may also want to inspect ECS task health and CloudWatch logs in AWS.

## Cleanup

To destroy the deployed infrastructure:

```bash
cd terraform
terraform destroy -var 'admin_cidr_ingress=YOUR.IP.ADDR.ESS/32'
```

## Notes

- The ECS service currently deploys into public subnets to keep the example simple and avoid NAT Gateway cost.
- The task definition references a prebuilt Docker image tag in `terraform/templates/tasks/app.json`, so make sure the referenced image exists before deploying.
- This repository is best treated as a learning/demo project rather than a production-ready template.
