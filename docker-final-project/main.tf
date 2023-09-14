terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.16.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

variable "secgrp-dynamic-ports" {
  default = [ 22,80,443,8080,5000]
}

variable "instance_type" {
  default = "t2.micro"
}

resource "aws_security_group" "allow_ssh2" {
  name        = "allow_ssh2"
  description = "Allow SSH inbound traffic"

  dynamic "ingress" {
    for_each = var.secgrp-dynamic-ports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

  egress {
    description = "Outbound Allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "tf-ec2" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name = "usa_key"
  vpc_security_group_ids = [ aws_security_group.allow_ssh2.id ]

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("usa_key.pem")
    host= self.public_ip
  }

  provisioner "file" {
    source = "bookstore-api.py"
    destination = "/home/ec2-user/bookstore-api.py"
  }
    provisioner "file" {
    source = "db_password.txt"
    destination = "/home/ec2-user/db_password.txt"
  }
  provisioner "file" {
    source = "Dockerfile"
    destination = "/home/ec2-user/Dockerfile"
  }
  
  provisioner "file" {
    source = "requirements.txt"
    destination = "/home/ec2-user/requirements.txt"
  }

  provisioner "file" {
    source = "docker-compose.yaml"
    destination = "/home/ec2-user/docker-compose.yaml"
  }

  user_data = filebase64("user-data.sh")
      tags = {
      Name = "Web Server of Bookstore"
  }
}


output "myec2-public-ip" {
  value = aws_instance.tf-ec2.public_ip
}
output "ssh-connection-command" {
  value = "ssh -i ${aws_instance.tf-ec2.key_name}.pem ec2-user@${aws_instance.tf-ec2.public_ip}"
}
