#################################
# VPC
#################################
resource "aws_vpc" "name" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true     
  enable_dns_hostnames = true
  tags = {
    Name = "tej-vpc"
  }
}

#################################
# Public Subnets
#################################
resource "aws_subnet" "pub1" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "pub-sub-1"
  }
}

resource "aws_subnet" "pub2" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "pub-sub-2"
  }
}

#################################
# Internet Gateway & Route Table
#################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "tej-igw"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "pub-rt"
  }
}

resource "aws_route_table_association" "pub1_assoc" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "pub2_assoc" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.pub-rt.id
}

#################################
# Security Group (Frontend/Backend)
#################################
resource "aws_security_group" "name" {
  vpc_id      = aws_vpc.name.id
  description = "allow"

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
}

#################################
# EC2 Instances
#################################
resource "aws_instance" "name" {
  ami                         = "ami-00ca32bbc84273381"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.pub1.id
  vpc_security_group_ids      = [aws_security_group.name.id]
  associate_public_ip_address = true
  tags = {
    Name = "frontend-server"
  }
}

resource "aws_instance" "ec2" {
  ami                         = "ami-00ca32bbc84273381"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.pub2.id
  vpc_security_group_ids      = [aws_security_group.name.id]
  associate_public_ip_address = true
  tags = {
    Name = "backend-server"
  }
}

#################################
# Private Subnets (for DB)
#################################
resource "aws_subnet" "pvt_sub_1" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.name.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "pvt-sub-1"
  }
}

resource "aws_subnet" "pvt_sub_2" {
  cidr_block        = "10.0.3.0/24"
  vpc_id            = aws_vpc.name.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "pvt-sub-2"
  }
}

#################################
# RDS Security Group
#################################
resource "aws_security_group" "tej_sg" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "tej-sg"
  }

  ingress {
    description = "MySQL from backend subnet"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # backend subnet only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#################################
# DB Subnet Group
#################################
resource "aws_db_subnet_group" "subnet_group" {
  name       = "db-subnetgroup"
  subnet_ids = [
    aws_subnet.pvt_sub_1.id,
    aws_subnet.pvt_sub_2.id
  ]
  tags = {
    Name = "db-subnetgroup"
  }
}

#################################
# RDS Instance
#################################
resource "aws_db_instance" "rds" {
  identifier              = "database-3"
  engine                  = "mysql"
  engine_version          = "8.0.42"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "test"
  username                = "admin"
  password                = "Veera#1234"
  port                    = 3306

  vpc_security_group_ids  = [aws_security_group.tej_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name

  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  multi_az                = false
  backup_retention_period = 7

  tags = {
    Name = "test-db"
  }
}

#################################
# Target Groups
#################################
resource "aws_lb_target_group" "fe_tg" {
  name     = "fe-tg"
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

  tags = {
    Name = "fe-tg"
  }
}

resource "aws_lb_target_group" "be_tg" {
  name     = "be-tg"
  port     = 80   # ✅ fixed (backend listens on 80, not 3000)
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

  tags = {
    Name = "be-tg"
  }
}

#################################
# Load Balancers
#################################
resource "aws_lb" "frontend_lb" {
  name               = "frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.name.id]
  subnets            = [aws_subnet.pub1.id, aws_subnet.pub2.id]

  tags = {
    Name = "frontend-lb"
  }
}

resource "aws_lb" "backend_lb" {
  name               = "backend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.name.id]
  subnets            = [aws_subnet.pub1.id, aws_subnet.pub2.id]

  tags = {
    Name = "backend-lb"
  }
}

#################################
# Listeners
#################################
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fe_tg.arn
  }

  depends_on = [aws_lb_target_group.fe_tg]
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.be_tg.arn
  }

  depends_on = [aws_lb_target_group.be_tg]
}

#################################
# Attach EC2s to Target Groups
#################################
resource "aws_lb_target_group_attachment" "frontend_attach" {
  target_group_arn = aws_lb_target_group.fe_tg.arn
  target_id        = aws_instance.name.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "backend_attach" {
  target_group_arn = aws_lb_target_group.be_tg.arn
  target_id        = aws_instance.ec2.id
  port             = 80   # ✅ fixed (backend listens on 80, not 3000)
}
