provider "aws" {
  region  = "eu-central-1"
}

# Store state data on S3
terraform {
  backend "s3" {
    bucket  = "colognedemo-terraform-state"
    region  = "eu-central-1"
  }
}

variable "deploymentId" {
  type    = "string"
  default = "Deployments-1"
}

variable "environmentId" {
  type    = "string"
  default = "Environments-1"
}

variable "apiKey" {
  type    = "string"
  default = "API-V0DIUWFKBIIJ9YAB0IGFKHVIGJY"
}

data "template_file" "user_data" {
  template = "${file("user_data.tpl")}"

  vars {
    deploymentId  = "${var.deploymentId}"
    environmentId = "${var.environmentId}"
    apiKey        = "${var.apiKey}"
  }
}

data "aws_subnet" "public_a" {
  filter {
    name = "tag:Name"
    values = ["Production Subnet (Public A)"]
  }
}

data "aws_security_group" "main" {
    name = "Main"
}


resource "aws_instance" "web" {
  ami                    = "ami-e62d0b0d"
  instance_type          = "t2.small"
  key_name = "RobW-Frankfurt"
  subnet_id              = "${data.aws_subnet.public_a.id}"                # Management Private A
  vpc_security_group_ids = ["${data.aws_security_group.main.id}"]
  user_data              = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name       = "Test WebServer 2"
    Deployment = "${var.deploymentId}"
  }
}
