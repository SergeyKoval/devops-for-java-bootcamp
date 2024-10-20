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
  cidr_ipv4         = "${aws_instance.task2-instance2-u.private_ip}/32"
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "task2-instance1-sg-rule2" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4         = "${aws_instance.task2-instance2-u.private_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "task2-instance1-sg-rule3" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4         = "${aws_instance.task2-instance2-u.private_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "task2-instance1-sg-rule4" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4         = "${aws_instance.task2-instance2-u.private_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "task2-instance1-sge-rule1" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4   = "${aws_instance.task2-instance2-u.private_ip}/32"
  from_port   = -1
  ip_protocol = "icmp"
  to_port     = -1
}

resource "aws_vpc_security_group_egress_rule" "task2-instance1-sge-rule2" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4   = "${aws_instance.task2-instance2-u.private_ip}/32"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "task2-instance1-sge-rule3" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4   = "${aws_instance.task2-instance2-u.private_ip}/32"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "task2-instance1-sge-rule4" {
  security_group_id = aws_security_group.task2-instance1-sg-private.id
  cidr_ipv4   = "${aws_instance.task2-instance2-u.private_ip}/32"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

data "aws_ami" "amazon-linux-2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "task2-instance1-al" {
  ami           = data.aws_ami.amazon-linux-2023.id
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
