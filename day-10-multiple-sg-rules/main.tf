resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
  tags={
    name="tej-vpc"
  }
}
resource "aws_subnet" "name" {
vpc_id = aws_vpc.name.id
cidr_block = "10.0.0.0/24"
}
resource "aws_subnet" "public1" {
    vpc_id=aws_vpc.name.id
    cidr_block = "10.0.1.0/24"
    tags = {
      name="pub-sub-1"
      availability_zone="us-east-1a"
    }
  
}
resource "aws_subnet" "public2" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.2.0/24"
    tags = {
      name="pub-sub-2"
      availability_zone="us-east-1b"
    }
  
}
resource "aws_internet_gateway" "name" {
  vpc_id= aws_vpc.name.id
  tags={
    name = "tej-igw"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.name.id
  }

  tags = {
    Name = "tej-public-rt"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_instance" "ec2" {
  ami="ami-00ca32bbc84273381"
  instance_type = "t2.micro"
  vpc_security_group_ids  = [aws_security_group.tej-sg.id]
  tags={
    Name="instance-Tej"
  }
}
resource "aws_security_group" "tej-sg" {
    name="tej-sg"
    description = "security group"
  ingress = [
    for port in [22,80,443,3306,8080]:{
    description = "inbound rules"
    from_port = port
    to_port = port
    protocol ="tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_blocks=[]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    }
  ]
}