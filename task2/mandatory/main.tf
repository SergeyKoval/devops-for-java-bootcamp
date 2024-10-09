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
