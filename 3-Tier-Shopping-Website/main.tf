#################################
# Provider
#################################
provider "aws" {
  region = "us-east-1"
}

#################################
# VPC
#################################
resource "aws_vpc" "name" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true     
  enable_dns_hostnames = true
  tags = {
    Name = "tejus-vpc"
  }
}

#################################
# Public Subnets
#################################
resource "aws_subnet" "pub1" {
  vpc_id                  = aws_vpc.name.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "pub-sub-1" }
}

resource "aws_subnet" "pub2" {
  vpc_id                  = aws_vpc.name.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "pub-sub-2" }
}

#################################
# Private Subnets (for DB)
#################################
resource "aws_subnet" "pvt_sub_1" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.name.id
  availability_zone = "us-east-1a"
  tags = { Name = "pvt-sub-1" }
}

resource "aws_subnet" "pvt_sub_2" {
  cidr_block        = "10.0.3.0/24"
  vpc_id            = aws_vpc.name.id
  availability_zone = "us-east-1b"
  tags = { Name = "pvt-sub-2" }
}

#################################
# Internet Gateway & Route Table
#################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.name.id
  tags   = { Name = "tej-igw" }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "pub-rt" }
}

resource "aws_route_table_association" "pub1_assoc" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub2_assoc" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.pub_rt.id
}

#################################
# Security Groups
#################################
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP, HTTPS, and SSH traffic"
  vpc_id      = aws_vpc.name.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-sg" }
}

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MySQL traffic from web servers"
  vpc_id      = aws_vpc.name.id

  ingress {
    description     = "MySQL from web servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "db-sg" }
}

#################################
# EC2 Instances (frontend & backend)
#################################
# (Your frontend and backend EC2 blocks remain unchanged)
# ...

#################################
# DB Subnet Group
#################################
resource "aws_db_subnet_group" "subnet_group" {
  name       = "db-subnetgroup"
  subnet_ids = [aws_subnet.pvt_sub_1.id, aws_subnet.pvt_sub_2.id]
  tags       = { Name = "db-subnetgroup" }
}

#################################
# RDS Instance
#################################
resource "aws_db_instance" "rds" {
  identifier             = "shopping-db"
  engine                 = "mysql"
  engine_version         = "8.0.42"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "Teju"
  username               = "admin"
  password               = "Teju1234"
  port                   = 3306
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  multi_az               = false
  backup_retention_period = 7

  parameter_group_name = "default.mysql8.0"

  tags = { Name = "shopping-db" }
}

#################################
# Target Groups
#################################
resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.name.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.name.id

  health_check {
    path                = "/products.php"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#################################
# Load Balancers
#################################
resource "aws_lb" "front_lb" {
  name               = "front-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.pub1.id, aws_subnet.pub2.id]
}

resource "aws_lb" "back_lb" {
  name               = "back-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.pub1.id, aws_subnet.pub2.id]
}

#################################
# Listeners (fixed names)
#################################
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.front_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.back_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

#################################
# Target Group Attachments (fixed names)
#################################
resource "aws_lb_target_group_attachment" "frontend_attach" {
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = aws_instance.frontend.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "backend_attach" {
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id        = aws_instance.backend.id
  port             = 3000
}

#################################
# Outputs (fixed names)
#################################
output "frontend_url" {
  description = "Frontend Load Balancer URL"
  value       = "http://${aws_lb.front_lb.dns_name}"
}

output "backend_url" {
  description = "Backend Load Balancer URL"
  value       = "http://${aws_lb.back_lb.dns_name}"
}

output "database_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.rds.endpoint
}
