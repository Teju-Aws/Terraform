provider "aws" {
  region = "ap-south-1"
}

# VPC (fixed: aws_pc → aws_vpc)
resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tej-vpc"
  }
}

# EC2 Instance (fixed: instance_type needs quotes)
resource "aws_instance" "main" {
  ami           = "ami-0d0ad8bb301edb745"
  instance_type = "t2.micro"
  subnet_id     = aws_vpc_name.id
  vpc_security_group_ids = [aws_security_group.name.id]
}

# Security Group
resource "aws_security_group" "name" {
  name        = "tej-sg"
  description = "Allow traffic"
  vpc_id      = aws_vpc.name.id
}

# Dynamic Security Group Rules
resource "aws_security_group_rule" "security_group_rule" {
  for_each = var.allowed_ports

  type              = "ingress"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
  cidr_blocks       = [each.value]
  protocol          = "tcp"
  security_group_id = aws_security_group.name.id
}
