# Task 2 extra part

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
- Complete  step 1, but AMI ID cannot be hardcoded. You can hardcode the operation system name, version, etc.
- Step 3 read as:
- - EC2 Amazon Linux should have outgoing and incoming access: ICMP, TCP/22, TCP/80, TCP/443, only to EC2 Ubuntu.
- On EC2 Amazon Linux install nginx (note. Remember about step 7, the task can be done in any way, it is not necessary to use terraform)
- - Create a web page with the text “Hello World”. This page must be visible from the  EC2 Ubuntu.

## Difference from previous [mandatory](/task2/mandatory/README.md) task

- Create custom AMI from Amazon Linux 2023 instance with installed nginx with "Hello world" page, so we don't need package installation on infrastructure creation for the instance in private subnet without internet
- Change private subnet to route only to/from ubuntu instance on public subnet
- Change instance creation to use additional aws_ami data with filter instead of specifying AMI id

## Public subnet ubuntu instance difference

Whole terraform [script](/task2/extra/instance2-u.tf)

Difference:

```terraform
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
```

## Private subnet ubuntu instance difference

Whole terraform [script](/task2/extra/instance1-al.tf):

Difference:

```terraform
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
    values = ["task2-instance1-image"]
  }
}

resource "aws_instance" "task2-instance1-al" {
  ami           = data.aws_ami.amazon-linux-2023.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.task2-private.id
  key_name      = "task1-instance1-key"
  vpc_security_group_ids = [aws_security_group.task2-instance1-sg-private.id]
  tags = {
    Name = "task2-instance1-al"
    task = "task2"
  }
}
```

![](/task2/extra/images/aws_instance1.png)

![](/task2/extra/images/ssh_instance2_curl.png)
