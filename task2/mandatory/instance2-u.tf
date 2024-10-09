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

resource "aws_instance" "task2-instance2-u" {
  ami                         = "ami-0866a3c8686eaeeba"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.task2-public.id
  key_name                    = "task1-instance2-key"
  vpc_security_group_ids      = [aws_security_group.task2-instance2-sg-public.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true
  user_data = <<-EOF
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
                content: LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQ21GbGN6STFOaTFqZEhJQUFBQUdZbU55ZVhCMEFBQUFHQUFBQUJDblRlc0xXNwpaMDhJcHlaTFlBdUJVU0FBQUFHQUFBQUFFQUFBR1hBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFCZ1FESDRuZEx6OEpzCnFnMUNPaVRqaU02eXVPd0NMQzJNUVluOE96VG1LbjlsNUEvRHFyYUxmT282NnJGQUhLVHJkTWwxTm50SERvRTlqaDFoMEwKWUYvRXF2djk2SzRtU2J1SXphemlqWTNOamV0YTA4WWZBVldjbkhQV2hteVVMSDFpM1Y0aUVOc2VIRm1YSGJZSGtzSWY0bQpKbzRTb0gzUUkxNXl5T2FFT3Z0WSsvc0w5dU9IdjZFYXZ4NkdQYmpNUndlNTVQMmhtTk1ORzY1cTVqNGo2blBiWXJjNUxtCmdrSU5STE5ycnNGWFlIZ1J6MmMwalhyVHcxVXJTdWFiaU5LdmYyMlFiTUVQL3ZFaDIzdFN3SjI0NFo3K2NIQUd5VGhxc24KNFFudUcwMmlQY1I4LzhHVXJrcFNOQUhWc2pqSXBabXJBdWNmOUNicnRHWGR0NnUwZEpjczJnTkVmK2RDOGlZVmJTN3V5ZApkTWV3cStKOUpTcE5NQ21rUGhGT2YzOG4wRXBpZXdhUE5Uckw3VzBaajE3QzJhQ2pYOHVZdlhubXBjWGd4NW8zNTdnZkdoCnBjR0hjWmUzditFMnJhVnVQR0U1Si8rQUlzcjVjYjZtS3F2OEpvNGRBVmZ0eFh2akF1UEJsVzZDMkpidkJndmZMZnFqVjgKbkJ5MlZGaWJCNm8rVUFBQVdRMUtOYTJidVg0L3M3RUpQZVN4azFHR2N5NEdBYkdmS3R4Syt0d2pTWmlTT1kzd25PSlp4UgpNOXBCdWRNci9paW5QN3U3blM1SnprZXYwUnV6ZGpaVGp2cWZuNDJiWVppTzFCUEcxZFVNeVByZktHSDhGSGV4MS85R2JJCnkvbDVidXR6a2NZRHZoNnI4dy82dDJvRnpIeWduZXpzeExhdGI5aTliZTRmc2Q5U0hEVTNYVldnanVSSFo5bVV3azdzb2UKTzY0T1VtVXZ6RVRHSGtQSTZDV1dPdVFidEtSVFdKTy9YSHlFK0dHNk1XMVBXZFJKNHB6ai9DYkNYU3lsb01aN3lNb2I4WApsTHJmR1IyR3ZVUkFERWVjWjVocjNuUzFpdmdkTEVUSHVoT2dJMmtLdjZSL3dGOGk2a2Q1KzMxOWd6NE1JenVHaTZ3K2kzCnVWejVNcVF5QldveEpqWlU0T3RKR1pWejh1ZjhLajh1cktEYkp5OE5zNy9JZHdqRy9MT010clBGVUZsTEJzMUEzVzB1SEYKVlVXK3FFNjNPMVN0YXZiZGJwL0hwUkQ0ZVN0RWxJZGVpSmRhZlhEeGsxRnRaRktDN3REcjB4KzVDMDNHV3lxTkM5clMyagpWSTlrQ1FIemF0MlY1TFhJK0xkYnN0Y3E3Q2YxMFd6ckRhZ2RBZk1nWmIwVkJUOUYvVXN4QnV2TFZwc2U2Snd4Y2hrRkV3ClBBUmR5TmFyK0ZWanoxSmIrMEVqdlFuN0VCRXcxcm5wVU1BS2crU3RZWi8rRkVZenF3dW1iRXZqVUxtcXVPWmNOS1h3SUwKbUVQTWJYVDY4RjlJLzRvSytJeVVZYzRETzVvRVN5SHVENWp4YUkxcjZ3Y0k4d2szRWtvSTlUYzlnTjJJNk9ZSkhHSEF3dApqZittWGpxcGY0LzVRck9oR1F3WEJzSUdlZk5GMVlnU01OeTEra0dQbGQwaHRHUkJMRXczaWRnQWtvSWxHZXVaenNJd1VrCjVIV2oxbzJGWXFPd1oyQnJGWk1UMjE1bC9hUU1mMHg2QjUyL2l3WlpWd3JhVnYvaDh6djlvYWlQVUY0RFB3dGxkdjE4b3MKeitkN21Cdmc5eS81dGxQUmJxclltZDQvSEtYOU5WMWlWbW51VmdVUjQ5L0Z0SXRYMXFzY0lZTE1lc2g1MXJSdmF3VjcwaApCcnBERGlIQzV6ZmkzdG9RR3NuL1M2cUUvQVdJQ2F6UGdpZk1pQS9sdGJsVTRaVUhMV3JCeFNhYmNOaVVPOXNIZVJIQnNOCkcvVmk5UjlaeWczSmttaDhSK2I3VDMyOUsyaVRSK1krSC90UTJTdHNlSDVIQVJhR01SeDRDckMvOUdhQ3hqVmNSWFJldkoKL1E0ZEVaYUZQQk5MV2lTL1VscTVDVURQbjE2TU40UDI5KzU4WlAvbzlQUHc2bGhLNTVDUWFud1FEQ3BaajNwSm9xcCtCZgpySmc0TGZrS2ZkUmZCWGJoZ29RZmg1c0EzYkxubGZwUlp6N2FCRVp0UlNsUDZvNGYrK1JoUW55dk93RkJQV29XRnBCUWVXCmV3cmtmdjJEMnZCNzdwTVlLTGJpSWx4Vm9Ra0lrWmYzcmN4TUNmbERkeXdkQUFweGNxenJqR0dBSnRDQmZqWHFZQVFlVzUKN0lrN0l5akxwOHZFQURYeDgxamd6Q3U5L0ErNElRRzNHOVVmREFmdjBXK2pVaC9QZjh2SzFpTWc3YW5DNFNBaUY5bXc2VApPa0tUK0lDdWNzNVBuVDVlSVVzeThab2NmR3I4a2I3alNlVkgxMmFMdG5lRjJ0VVBpaFpxb08xVWpmUWo3KzFXR2gvYVJ0Cis5Rjc4a0U0UFI2eEVvWlJqdGpjQlBUREd3c0FEWW9oc1hoSGtlT1p3NmxnWXU3Si8wUktIbTBWUDRlNW9IMUFieVNEL0wKaFRQZjJ5ZkZrQksyczVCNGZiRHUvd0o4SDVIZHJMcHY2Vk0xSVNUckltRlk0TFJSQThnZGYybktrbTRRZHp5by9CdEpaZApPdERSM1NDUFhTSHRlYVk5RXh1QzU0ejdaOW1iK0lpMjB3WWxESllWUjFCYlpDNmlwZmh0d0t3ek1XMmthcHlkVG1xT3V6CkF0TGRYV01CdE9NS0Uxbk0zZnZjckY4NWRoTVR3dTdkNy83TytJaWw3T29NODJRSWpmZnpSalF0NXJPdlEzZHZab0RwMmwKR0poTCtsV3RkZkw4K1lXbkV3SGVBdHhZOGUzdHpueUV5K2RxSmpiMmhQdkVLWk1BVUlqRzJVeldtcHd3d2o5YkZXTm9hdwpwYW5zTGNVWW5wYjZTNCt0U2JsYXFZYWVoY2gybVdVZkE0Y3AxOGNCakFIYkFEeEM2NFpMd1d0WTlVeW95YXZITFlqaEhCCjJ0K1pISERUVHRHbWMzeVVlcG5mZWc5NU5ZL2J2NEUzMlRTaFluVWtpS3d1cDhUYjc5NFdtU0psT0hJQzRnQy83ZHlML2QKRmRNcUFSbWZ0c05RbEdkN09qYStnT2xrUnRvPQotLS0tLUVORCBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0K
              - path: /var/www/html/info.php
                encoding: b64
                permissions: '0664'
                content: PD9waHAKZnVuY3Rpb24gZ2V0T1NJbmZvcm1hdGlvbigpCiAgICB7CiAgICAgICAgaWYgKGZhbHNlID09IGZ1bmN0aW9uX2V4aXN0cygic2hlbGxfZXhlYyIpIHx8IGZhbHNlID09IGlzX3JlYWRhYmxlKCIvZXRjL29zLXJlbGVhc2UiKSkgewogICAgICAgICAgICByZXR1cm4gbnVsbDsKICAgICAgICB9CgogICAgICAgICRvcyAgICAgICAgID0gc2hlbGxfZXhlYygnY2F0IC9ldGMvb3MtcmVsZWFzZScpOwogICAgICAgICRsaXN0SWRzICAgID0gcHJlZ19tYXRjaF9hbGwoJy8uKj0vJywgJG9zLCAkbWF0Y2hMaXN0SWRzKTsKICAgICAgICAkbGlzdElkcyAgICA9ICRtYXRjaExpc3RJZHNbMF07CgogICAgICAgICRsaXN0VmFsICAgID0gcHJlZ19tYXRjaF9hbGwoJy89LiovJywgJG9zLCAkbWF0Y2hMaXN0VmFsKTsKICAgICAgICAkbGlzdFZhbCAgICA9ICRtYXRjaExpc3RWYWxbMF07CgogICAgICAgIGFycmF5X3dhbGsoJGxpc3RJZHMsIGZ1bmN0aW9uKCYkdiwgJGspewogICAgICAgICAgICAkdiA9IHN0cnRvbG93ZXIoc3RyX3JlcGxhY2UoJz0nLCAnJywgJHYpKTsKICAgICAgICB9KTsKCiAgICAgICAgYXJyYXlfd2FsaygkbGlzdFZhbCwgZnVuY3Rpb24oJiR2LCAkayl7CiAgICAgICAgICAgICR2ID0gcHJlZ19yZXBsYWNlKCcvPXwiLycsICcnLCAkdik7CiAgICAgICAgfSk7CgogICAgICAgIHJldHVybiBhcnJheV9jb21iaW5lKCRsaXN0SWRzLCAkbGlzdFZhbCk7CiAgICB9CgpmdW5jdGlvbiBnZXRTeXN0ZW1NZW1JbmZvKCkKewogICAgJGRhdGEgPSBleHBsb2RlKCJcbiIsIGZpbGVfZ2V0X2NvbnRlbnRzKCIvcHJvYy9tZW1pbmZvIikpOwogICAgJG1lbWluZm8gPSBhcnJheSgpOwogICAgZm9yZWFjaCAoJGRhdGEgYXMgJGxpbmUpIHsKICAgICAgICBsaXN0KCRrZXksICR2YWwpID0gZXhwbG9kZSgiOiIsICRsaW5lKTsKICAgICAgICAkbWVtaW5mb1ska2V5XSA9IHRyaW0oJHZhbCk7CiAgICB9CiAgICByZXR1cm4gJG1lbWluZm87Cn0KCiRtZW1faW5mbyA9IGdldFN5c3RlbU1lbUluZm8oKTsKJG9zX2luZm8gPSBnZXRPU0luZm9ybWF0aW9uKCk7CiRieXRlcyA9IGRpc2tfZnJlZV9zcGFjZSgiLyIpOwokc2lfcHJlZml4ID0gYXJyYXkoICdCJywgJ0tCJywgJ01CJywgJ0dCJywgJ1RCJywgJ0VCJywgJ1pCJywgJ1lCJyApOwokYmFzZSA9IDEwMjQ7CiRjbGFzcyA9IG1pbigoaW50KWxvZygkYnl0ZXMgLCAkYmFzZSkgLCBjb3VudCgkc2lfcHJlZml4KSAtIDEpOwoKcHJpbnRfcigiPGRpdj5IZWxsbyB3b3JsZCBmb3IgdGFzayAxPC9kaXY+Iik7CgpwcmludF9yKCI8ZGl2PkZyZWUgZGlzayBzcGFjZTogIi5zcHJpbnRmKCclMS4yZicgLCAkYnl0ZXMgLyBwb3coJGJhc2UsJGNsYXNzKSkgLiAnICcgLiAkc2lfcHJlZml4WyRjbGFzc10uIjwvZGl2PiIpOwpwcmludF9yKCI8ZGl2PlNlcnZlciBPUzogIi4kb3NfaW5mb1sncHJldHR5X25hbWUnXS4iPC9kaXY+Iik7CnByaW50X3IoIjxkaXY+VG90YWwgbWVtb3J5OiAiLiRtZW1faW5mb1snTWVtVG90YWwnXS4iPC9kaXY+Iik7CnByaW50X3IoIjxkaXY+RnJlZSBtZW1vcnk6ICIuJG1lbV9pbmZvWydNZW1GcmVlJ10uIjwvZGl2PjwvYnI+PC9icj48L2JyPiIpOwoKcHJpbnRfcigiPGRpdj5SdW5uaW5nIHByb2Nlc3Nlczo8L2Rpdj4iKTsKJGV4ZWNzdHJpbmc9J3BzIGZhdXgnOwokb3V0cHV0PSIiOwpleGVjKCRleGVjc3RyaW5nLCAkb3V0cHV0KTsKZm9yZWFjaCgkb3V0cHV0IGFzICRvdXRwdXRfaXRlbSkgewogIHByaW50X3IoIjxkaXY+Ii4kb3V0cHV0X2l0ZW0uIjwvZGl2PiIpOwp9Cj8+Cg==
              sh_authorized_keys:
              - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWEk7K7rngzzusR1VkEvQ5K67s0LkxgSEYaV4x4vqk4/81UE8N3W64a/v124q61fhT647k68Mv+F2EVnd87z4ROK+oRsjmGDFIJAAGxuWVw4XdYFO/1xdX/Zt9vjS1xnJhPOwnCmbPeYRHjtS1mYdAiO6yDmHmpK3xvsG79AOx9f9jmk4U04vRHwQEkUshjqaFE6BEzBKcWlndnted+W+ADvNZTFVew12fgPBpgMOFAEYqfaybwaBz76+qp8lByFF1vi1HnXjZ8tWVzUFve2/iyRFe/kHERF6bL7cl3jjaipoxzyGo6uIK/kQ4TF2FxMze3sb/pIlN/dH6by/l2A+MUpYaeUotlMKlreZ1jhF2tU5b9+bAWXW8OBNkj+4zaEE3IatRVWciVIyju7mSCrDztxMWO+xxwr4JQn6kpyuZXuIiYkivzYwoN9p/dum04ijvc8AFrFcVrfscpYvaNeuPmBJ4MUGtErppDyFZVGnVWx8cerhXJCAgEWugr6yuenc= instance2_id_rsa
              EOF

  tags = {
    Name = "task2-instance2-u"
    task = "task2"
  }
}
