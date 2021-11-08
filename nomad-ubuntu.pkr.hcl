packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "ami_prefix" {
  type    = string
  default = "server-nomad-consul"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "server" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t3.medium"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    "Name"        = "Nomad-Consul-image"
    "Environment" = "LAB Nomad"
    "OS_Version"  = "Ubuntu 16.04"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
    "Version"     = "one"
  }
}

build {
  sources = ["source.amazon-ebs.server"]

  provisioner "file" {
    source      = "./source/config/nomad.service"
    destination = "/tmp/nomad.service"
  }

  provisioner "file" {
    source      = "./source/config/consul.service"
    destination = "/tmp/consul.service"
  }

  provisioner "shell" {
    inline = [
      "sudo cp /tmp/nomad.service /etc/systemd/system/nomad.service",
      "sudo cp /tmp/consul.service /etc/systemd/system/consul.service",
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
    script = "./source/script/install-nomad-consul.sh"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
    custom_data = {
      AWS-AMI-management-page      = "https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=eu-west-3#Images:visibility=owned-by-me;search=server-nomad-consul-;sort=tag:Name"
      AWS-snapshot-management-page = "https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=eu-west-3#Snapshots:visibility=owned-by-me;sort=tag:Name"
    }
  }
}

# AWS-AMI-management-page = "https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=eu-west-3#Images:visibility=owned-by-me;search=learn-packer-linux-aws;sort=tag:Name"