#!/bin/bash
hostnamectl set-hostname docker_instance
dnf update -y
dnf install docker -y
yum install python3 -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
# install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose
# sudo curl -SL https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64 \
# -o /usr/local/bin/docker-compose #bu komutta kullanılabilir
sudo chmod +x /usr/local/bin/docker-compose
cd /home/ec2-user 
docker-compose up -d