resource "aws_vpc" "main" {
    cidr_block="10.0.0.0/16"
  tags ={
    Name ="Tej-vpc"
  }
}
resource "aws_subnet" "pvt_sub_1" {
    cidr_block = "10.0.0.0/24"
    vpc_id = aws_vpc.main.id
    availability_zone = "ap-south-1a"
  tags={
    Name ="pvt-sub-1"
  }
}
resource "aws_subnet" "pvt_sub_2" {
    cidr_block = "10.0.1.0/24"
    vpc_id = aws_vpc.main.id
    availability_zone = "ap-south-1b"
  tags={
    Name ="pvt-sub-2"
  }
}
resource "aws_security_group" "tej_sg" {
vpc_id = aws_vpc.main.id
tags ={
    name = "tej-sg"
}
ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
}
ingress {
    from_port = 3306
    to_port   = 3306
    protocol     = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
egress {
    from_port = 0
    to_port = 0
    protocol= -1
    cidr_blocks = ["0.0.0.0/0"]
}
  
}
resource "aws_security_group" "ec2_sg" {
vpc_id = aws_vpc.main.id
tags ={
    name = "ec2-sg"
}
}
resource "aws_db_subnet_group" "subnet_group" {
name = "db-subnetgroup"
subnet_ids = [aws_subnet.pvt_sub_1.id,
              aws_subnet.pvt_sub_2.id]
tags ={
    Name = "db-subnetgroup"
}
}
resource "aws_db_instance" "rds" {
  identifier = "database-3"
  engine = "mysql"
  engine_version = "8.0.42"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_name = "Teju"
  username="admin"
  password ="Teju1234"
  vpc_security_group_ids = [aws_security_group.tej_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name
  publicly_accessible = false
  port=3306
  skip_final_snapshot     = true
  deletion_protection     = false
     multi_az                = false
      backup_retention_period = 7
      tags={
        name ="Teju-database"
      }
}
resource "aws_db_instance" "read_replica" {
  identifier             = "replica-database-3"
  replicate_source_db    = aws_db_instance.rds.arn
  instance_class         = "db.t3.micro"
  publicly_accessible    = false
  #db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.tej_sg.id]
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = {
    Name = "Read Replica"
  }
}

#variable "db_password" {
  #description = "RDS master password"
  #type        = string
  #sensitive   = true
#}
