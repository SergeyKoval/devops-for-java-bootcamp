provider "aws" {
  region = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "devops-for-java-bootcamp"
}

resource "aws_vpc" "task3" {
  cidr_block           = "11.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    task = "task3"
    Name = "task3-vpc"
  }
}

resource "aws_subnet" "task3-public" {
  vpc_id                  = aws_vpc.task3.id
  cidr_block              = "11.0.112.0/20"
  map_public_ip_on_launch = true
  tags = {
    task = "task3"
    Name = "task3-subnet-public"
  }
}

resource "aws_route_table_association" "task3-public-subnet-route-association" {
  subnet_id      = aws_subnet.task3-public.id
  route_table_id = aws_route_table.task3-public-route.id
}

resource "aws_internet_gateway" "task3-public-ig" {
  vpc_id = aws_vpc.task3.id

  tags = {
    task = "task3"
    Name = "task3-public-ig"
  }
}

resource "aws_route_table" "task3-public-route" {
  vpc_id = aws_vpc.task3.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task3-public-ig.id
  }

  tags = {
    task = "task3"
    Name = "task3-public-route"
  }
}

resource "aws_security_group" "task3-instance1-sg-public" {
  name   = "task3-instance1-sg-public"
  vpc_id = aws_vpc.task3.id
  tags = {
    task = "task3"
    Name = "task3-instance1-sg-public"
  }
}

resource "aws_vpc_security_group_ingress_rule" "task3-instance1-sg-rule1" {
  security_group_id = aws_security_group.task3-instance1-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "task3-instance1-sg-rule2" {
  security_group_id = aws_security_group.task3-instance1-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "task3-instance1-sg-rule3" {
  security_group_id = aws_security_group.task3-instance1-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "task3-instance1-sg-rule4" {
  security_group_id = aws_security_group.task3-instance1-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "task3-instance1-sge-rule1" {
  security_group_id = aws_security_group.task3-instance1-sg-public.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = -1
  ip_protocol = -1
  to_port     = -1
}

resource "aws_instance" "task3-instance1" {
  ami                         = "ami-0fff1b9a61dec8a5f"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.task3-public.id
  key_name                    = "task1-instance1-key"
  vpc_security_group_ids      = [aws_security_group.task3-instance1-sg-public.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true
  user_data = file("${path.module}/instance1-user-data.yml")
  tags = {
    Name = "task3-instance1"
    task = "task3"
  }
}