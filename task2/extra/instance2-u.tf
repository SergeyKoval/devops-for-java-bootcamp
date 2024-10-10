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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240927"]
  }
}

resource "aws_instance" "task2-instance2-u" {
  ami                         = data.aws_ami.ubuntu.id
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
