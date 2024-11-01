provider "aws" {
  region = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "devops-for-java-bootcamp"
}

resource "aws_vpc" "task4" {
  cidr_block           = "11.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    task = "task4"
    Name = "task4-vpc"
  }
}

resource "aws_subnet" "task4-public" {
  vpc_id                  = aws_vpc.task4.id
  cidr_block              = "11.0.112.0/20"
  map_public_ip_on_launch = true
  tags = {
    task = "task4"
    Name = "task4-subnet-public"
  }
}

resource "aws_route_table_association" "task4-public-subnet-route-association" {
  subnet_id      = aws_subnet.task4-public.id
  route_table_id = aws_route_table.task4-public-route.id
}

resource "aws_internet_gateway" "task4-public-ig" {
  vpc_id = aws_vpc.task4.id

  tags = {
    task = "task4"
    Name = "task4-public-ig"
  }
}

resource "aws_route_table" "task4-public-route" {
  vpc_id = aws_vpc.task4.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task4-public-ig.id
  }

  tags = {
    task = "task4"
    Name = "task4-public-route"
  }
}

resource "aws_security_group" "task4-instance1-sg-public" {
  name   = "task4-instance1-sg-public"
  vpc_id = aws_vpc.task4.id
  tags = {
    task = "task4"
    Name = "task4-instance1-sg-public"
  }
}

resource "aws_vpc_security_group_ingress_rule" "task4-instance1-sg-rule1" {
  security_group_id = aws_security_group.task4-instance1-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "task4-instance1-sg-rule2" {
  security_group_id = aws_security_group.task4-instance1-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "task4-instance1-sg-rule3" {
  security_group_id = aws_security_group.task4-instance1-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "task4-instance1-sg-rule4" {
  security_group_id = aws_security_group.task4-instance1-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "task4-instance1-sg-rule5" {
  security_group_id = aws_security_group.task4-instance1-sg-public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 50000
  to_port           = 50000
}

resource "aws_vpc_security_group_egress_rule" "task4-instance1-sge-rule1" {
  security_group_id = aws_security_group.task4-instance1-sg-public.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = -1
  ip_protocol = -1
  to_port     = -1
}

resource "aws_instance" "task4-instance1" {
  ami                         = "ami-0866a3c8686eaeeba"
  instance_type               = "t3a.medium"
  subnet_id                   = aws_subnet.task4-public.id
  key_name                    = "task1-instance1-key"
  vpc_security_group_ids      = [aws_security_group.task4-instance1-sg-public.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true
  user_data = file("${path.module}/instance1-user-data.yml")
  tags = {
    Name = "task4-instance1"
    task = "task4"
  }
}
