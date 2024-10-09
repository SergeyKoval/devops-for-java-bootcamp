# Task 2 mandatory part

## Requirements
- Create EC2 Instance t2.micro
- - Ubuntu
- - Amazon Linux
- Both instances must have a tag with names.
- EC2 Ubuntu must have Internet access, there must be incoming access: ICMP, TCP/22, 80, 443, and any outgoing access.
- EC2 Amazon Linux should not have access to the Internet, but must have outgoing and incoming access: ICMP, TCP/22, TCP/80, TCP/443 only on the local network where EC2 Ubuntu, EC2 Amazon Linux is located.
- On EC2 Ubuntu, install a web server (nginx/apache);
- - Create a web page with the text “Hello World” and information about the current version of the operating system. This page must be visible from the Internet.
- On EC2 Ubuntu install Docker, installation should be done according to the recommendation of the official Docker manuals 

## VPC resources

VPC was created with 2 subnets: private for the EC2 Amazon Linux instance and public for the EC2 Ubuntu

Terraform [script](/task2/mandatory/main.tf) for the VPC:

```terraform
provider "aws" {
  region = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "devops-for-java-bootcamp"
}

resource "aws_vpc" "task2" {
  cidr_block           = "11.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    task = "task2"
    Name = "task2-vpc"
  }
}
```

![](/task2/mandatory/images/aws_vpc_resource-map.png)

## Private subnet with EC2 Amazon Linux instance

Terraform [script](/task2/mandatory/instance1-al.tf) for the private subnet, which includes:

- subnet
- security group
- security group ingress and egress rules
- EC2 instance

```terraform
resource "aws_subnet" "task2-private" {
  vpc_id            = aws_vpc.task2.id
  cidr_block        = "11.0.128.0/20"
  tags = {
    task = "task2"
    Name = "task2-subnet-private"
  }
}

resource "aws_security_group" "task2-instance1-sg-private" {
  name   = "task2-instance1-sg-private"
  vpc_id = aws_vpc.task2.id
  tags = {
    task = "task2"
    Name = "task2-instance1-sg-private"
  }
}

resource "aws_vpc_security_group_ingress_rule" "task2-instance1-sg-rule1" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4         = aws_vpc.task2.cidr_block
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "task2-instance1-sg-rule2" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4         = aws_vpc.task2.cidr_block
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "task2-instance1-sg-rule3" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4         = aws_vpc.task2.cidr_block
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "task2-instance1-sg-rule4" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4         = aws_vpc.task2.cidr_block
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "task2-instance1-sge-rule1" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4   = aws_vpc.task2.cidr_block
  from_port   = -1
  ip_protocol = "icmp"
  to_port     = -1
}

resource "aws_vpc_security_group_egress_rule" "task2-instance1-sge-rule2" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4   = aws_vpc.task2.cidr_block
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "task2-instance1-sge-rule3" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4   = aws_vpc.task2.cidr_block
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "task2-instance1-sge-rule4" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4   = aws_vpc.task2.cidr_block
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_instance" "task2-instance1-al" {
  ami           = "ami-0fff1b9a61dec8a5f"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.task2-private.id
  key_name      = "task1-instance1-key"
  vpc_security_group_ids = [aws_security_group.task2-instance1-sg-private.id]
  user_data_replace_on_change = true
  user_data = file("${path.module}/instance1-user-data.yml")
  tags = {
    Name = "task2-instance1-al"
    task = "task2"
  }
}
```

And EC2 instance user data [script](/task2/mandatory/instance1-user-data.yml) in the separate file:

```yml
#cloud-config
repo_update: true
repo_upgrade: all
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDH4ndLz8Jsqg1COiTjiM6yuOwCLC2MQYn8OzTmKn9l5A/DqraLfOo66rFAHKTrdMl1NntHDoE9jh1h0LYF/Eqvv96K4mSbuIzazijY3Njeta08YfAVWcnHPWhmyULH1i3V4iENseHFmXHbYHksIf4mJo4SoH3QI15yyOaEOvtY+/sL9uOHv6Eavx6GPbjMRwe55P2hmNMNG65q5j4j6nPbYrc5LmgkINRLNrrsFXYHgRz2c0jXrTw1UrSuabiNKvf22QbMEP/vEh23tSwJ244Z7+cHAGyThqsn4QnuG02iPcR8/8GUrkpSNAHVsjjIpZmrAucf9CbrtGXdt6u0dJcs2gNEf+dC8iYVbS7uyddMewq+J9JSpNMCmkPhFOf38n0EpiewaPNTrL7W0Zj17C2aCjX8uYvXnmpcXgx5o357gfGhpcGHcZe3v+E2raVuPGE5J/+AIsr5cb6mKqv8Jo4dAVftxXvjAuPBlW6C2JbvBgvfLfqjV8nBy2VFibB6o+U= ubuntu-instance-key
```

It doesn't have public IP and security rules are limited to the internal network

![](/task2/mandatory/images/aws_instance1.png)

## Public subnet with EC2 Ubuntu instance

Terraform [script](/task2/mandatory/instance2-u.tf) for the public subnet, which includes:

- subnet
- route table 
- route table association with internet gateway
- security group
- security group ingress and egress rules
- EC2 instance

```terraform
resource "aws_subnet" "task2-public" {
  vpc_id                  = aws_vpc.task2.id
  cidr_block              = "11.0.112.0/20"
  map_public_ip_on_launch = true
  tags = {
    task = "task2"
    Name = "task2-subnet-public"
  }
}

resource "aws_route_table_association" "task2-public-subnet-route-association" {
  subnet_id      = aws_subnet.task2-public.id
  route_table_id = aws_route_table.task2-public-route.id
}

resource "aws_internet_gateway" "task2-public-ig" {
  vpc_id = aws_vpc.task2.id

  tags = {
    task = "task2"
    Name = "task2-public-ig"
  }
}

resource "aws_route_table" "task2-public-route" {
  vpc_id = aws_vpc.task2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task2-public-ig.id
  }

  tags = {
    task = "task2"
    Name = "task2-public-route"
  }
}

resource "aws_security_group" "task2-instance2-sg-public" {
  name   = "task2-instance2-sg-public"
  vpc_id = aws_vpc.task2.id
  tags = {
    task = "task2"
    Name = "task2-instance2-sg-public"
  }
}

resource "aws_vpc_security_group_ingress_rule" "task2-instance2-sg-rule1" {
  security_group_id = aws_security_group.task2-instance2-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "task2-instance2-sg-rule2" {
  security_group_id = aws_security_group.task2-instance2-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "task2-instance2-sg-rule3" {
  security_group_id = aws_security_group.task2-instance2-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "task2-instance2-sg-rule4" {
  security_group_id = aws_security_group.task2-instance2-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "task2-instance2-sge-rule1" {
  security_group_id = aws_security_group.task2-instance2-sg-public.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = -1
  ip_protocol = -1
  to_port     = -1
}

data "aws_secretsmanager_secret" "instance1-id-rsa" {
  arn = "arn:aws:secretsmanager:us-east-1:182399708502:secret:task2/instance2/instance1_id_rsa-pY90Jm"
}

data "aws_secretsmanager_secret_version" "instance1-id-rsa-version" {
  secret_id = data.aws_secretsmanager_secret.instance1-id-rsa.id
}

resource "aws_instance" "task2-instance2-u" {
  ami                         = "ami-0866a3c8686eaeeba"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.task2-public.id
  key_name                    = "task1-instance2-key"
  vpc_security_group_ids      = [aws_security_group.task2-instance2-sg-public.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/instance2-user-data.yml", {
    instance1_id_rsa = jsondecode(data.aws_secretsmanager_secret_version.instance1-id-rsa-version.secret_string)["private_rsa"]
  })
  tags = {
    Name = "task2-instance2-u"
    task = "task2"
  }
}
```

And EC2 instance user data [script](/task2/mandatory/instance2-user-data.yml) in the separate file:

```yaml
#cloud-config
repo_update: true
repo_upgrade: all
packages:
  - apache2
  - php
runcmd:
  - [ chown, "ubuntu:ubuntu", "/home/ubuntu/.ssh/instance1_id_rsa" ]
  - systemctl start apache2
  - sudo systemctl enable apache2
  - chmod 2775 /var/www
  - sudo apt-get install ca-certificates curl
  - sudo install -m 0755 -d /etc/apt/keyrings
  - sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  - sudo chmod a+r /etc/apt/keyrings/docker.asc
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  - sudo apt-get update
  - sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
write_files:
  - path: /home/ubuntu/.ssh/instance1_id_rsa
    encoding: b64
    permissions: '0600'
    content: ${jsonencode(instance1_id_rsa)}
  - path: /var/www/html/info.php
    encoding: b64
    permissions: '0664'
    content: PD9waHAKZnVuY3Rpb24gZ2V0T1NJbmZvcm1hdGlvbigpCiAgICB7CiAgICAgICAgaWYgKGZhbHNlID09IGZ1bmN0aW9uX2V4aXN0cygic2hlbGxfZXhlYyIpIHx8IGZhbHNlID09IGlzX3JlYWRhYmxlKCIvZXRjL29zLXJlbGVhc2UiKSkgewogICAgICAgICAgICByZXR1cm4gbnVsbDsKICAgICAgICB9CgogICAgICAgICRvcyAgICAgICAgID0gc2hlbGxfZXhlYygnY2F0IC9ldGMvb3MtcmVsZWFzZScpOwogICAgICAgICRsaXN0SWRzICAgID0gcHJlZ19tYXRjaF9hbGwoJy8uKj0vJywgJG9zLCAkbWF0Y2hMaXN0SWRzKTsKICAgICAgICAkbGlzdElkcyAgICA9ICRtYXRjaExpc3RJZHNbMF07CgogICAgICAgICRsaXN0VmFsICAgID0gcHJlZ19tYXRjaF9hbGwoJy89LiovJywgJG9zLCAkbWF0Y2hMaXN0VmFsKTsKICAgICAgICAkbGlzdFZhbCAgICA9ICRtYXRjaExpc3RWYWxbMF07CgogICAgICAgIGFycmF5X3dhbGsoJGxpc3RJZHMsIGZ1bmN0aW9uKCYkdiwgJGspewogICAgICAgICAgICAkdiA9IHN0cnRvbG93ZXIoc3RyX3JlcGxhY2UoJz0nLCAnJywgJHYpKTsKICAgICAgICB9KTsKCiAgICAgICAgYXJyYXlfd2FsaygkbGlzdFZhbCwgZnVuY3Rpb24oJiR2LCAkayl7CiAgICAgICAgICAgICR2ID0gcHJlZ19yZXBsYWNlKCcvPXwiLycsICcnLCAkdik7CiAgICAgICAgfSk7CgogICAgICAgIHJldHVybiBhcnJheV9jb21iaW5lKCRsaXN0SWRzLCAkbGlzdFZhbCk7CiAgICB9CgpmdW5jdGlvbiBnZXRTeXN0ZW1NZW1JbmZvKCkKewogICAgJGRhdGEgPSBleHBsb2RlKCJcbiIsIGZpbGVfZ2V0X2NvbnRlbnRzKCIvcHJvYy9tZW1pbmZvIikpOwogICAgJG1lbWluZm8gPSBhcnJheSgpOwogICAgZm9yZWFjaCAoJGRhdGEgYXMgJGxpbmUpIHsKICAgICAgICBsaXN0KCRrZXksICR2YWwpID0gZXhwbG9kZSgiOiIsICRsaW5lKTsKICAgICAgICAkbWVtaW5mb1ska2V5XSA9IHRyaW0oJHZhbCk7CiAgICB9CiAgICByZXR1cm4gJG1lbWluZm87Cn0KCiRtZW1faW5mbyA9IGdldFN5c3RlbU1lbUluZm8oKTsKJG9zX2luZm8gPSBnZXRPU0luZm9ybWF0aW9uKCk7CiRieXRlcyA9IGRpc2tfZnJlZV9zcGFjZSgiLyIpOwokc2lfcHJlZml4ID0gYXJyYXkoICdCJywgJ0tCJywgJ01CJywgJ0dCJywgJ1RCJywgJ0VCJywgJ1pCJywgJ1lCJyApOwokYmFzZSA9IDEwMjQ7CiRjbGFzcyA9IG1pbigoaW50KWxvZygkYnl0ZXMgLCAkYmFzZSkgLCBjb3VudCgkc2lfcHJlZml4KSAtIDEpOwoKcHJpbnRfcigiPGRpdj5IZWxsbyB3b3JsZCBmb3IgdGFzayAxPC9kaXY+Iik7CgpwcmludF9yKCI8ZGl2PkZyZWUgZGlzayBzcGFjZTogIi5zcHJpbnRmKCclMS4yZicgLCAkYnl0ZXMgLyBwb3coJGJhc2UsJGNsYXNzKSkgLiAnICcgLiAkc2lfcHJlZml4WyRjbGFzc10uIjwvZGl2PiIpOwpwcmludF9yKCI8ZGl2PlNlcnZlciBPUzogIi4kb3NfaW5mb1sncHJldHR5X25hbWUnXS4iPC9kaXY+Iik7CnByaW50X3IoIjxkaXY+VG90YWwgbWVtb3J5OiAiLiRtZW1faW5mb1snTWVtVG90YWwnXS4iPC9kaXY+Iik7CnByaW50X3IoIjxkaXY+RnJlZSBtZW1vcnk6ICIuJG1lbV9pbmZvWydNZW1GcmVlJ10uIjwvZGl2PjwvYnI+PC9icj48L2JyPiIpOwoKcHJpbnRfcigiPGRpdj5SdW5uaW5nIHByb2Nlc3Nlczo8L2Rpdj4iKTsKJGV4ZWNzdHJpbmc9J3BzIGZhdXgnOwokb3V0cHV0PSIiOwpleGVjKCRleGVjc3RyaW5nLCAkb3V0cHV0KTsKZm9yZWFjaCgkb3V0cHV0IGFzICRvdXRwdXRfaXRlbSkgewogIHByaW50X3IoIjxkaXY+Ii4kb3V0cHV0X2l0ZW0uIjwvZGl2PiIpOwp9Cj8+Cg==
sh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWEk7K7rngzzusR1VkEvQ5K67s0LkxgSEYaV4x4vqk4/81UE8N3W64a/v124q61fhT647k68Mv+F2EVnd87z4ROK+oRsjmGDFIJAAGxuWVw4XdYFO/1xdX/Zt9vjS1xnJhPOwnCmbPeYRHjtS1mYdAiO6yDmHmpK3xvsG79AOx9f9jmk4U04vRHwQEkUshjqaFE6BEzBKcWlndnted+W+ADvNZTFVew12fgPBpgMOFAEYqfaybwaBz76+qp8lByFF1vi1HnXjZ8tWVzUFve2/iyRFe/kHERF6bL7cl3jjaipoxzyGo6uIK/kQ4TF2FxMze3sb/pIlN/dH6by/l2A+MUpYaeUotlMKlreZ1jhF2tU5b9+bAWXW8OBNkj+4zaEE3IatRVWciVIyju7mSCrDztxMWO+xxwr4JQn6kpyuZXuIiYkivzYwoN9p/dum04ijvc8AFrFcVrfscpYvaNeuPmBJ4MUGtErppDyFZVGnVWx8cerhXJCAgEWugr6yuenc= instance2_id_rsa
```

It has public IP and DNS

![](/task2/mandatory/images/aws_public-subnet_routes.png)

![](/task2/mandatory/images/aws_instance2.png)
