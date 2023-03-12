provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Name = "hello-ecs"
      Repository = "https://github.com/ericdahl/hello-ecs"
    }
  }
}

data "aws_default_tags" "default" {}

locals {
  name = data.aws_default_tags.default.tags["Name"]
}