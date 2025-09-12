resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  tags ={
    Name ="tej-vpc"
  }
}
resource "aws_subnet" "name" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.0.0/24"
}
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.name.id
  
    cidr_block = "10.0.1.0/24"
    availability_zone       = "us-east-1a"
    tags ={
        Name ="Pub-sub-tej"
    }
}


resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.name.id
}
resource "aws_eip" "nat" {
  domain = "vpc"
}
resource "aws_nat_gateway" "name" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "tej-NAT-Gateway"
  }
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "tej-Private-Subnet"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.name.id
  }

  tags = {
    Name = "tej-Private-RT"
  }
}
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_internet_gateway" "name" {
  tags={
    Name = "teju-igw"
  }
vpc_id = aws_vpc.name.id
}
resource "aws_route_table" "name" {
    vpc_id =aws_vpc.name.id

 route{
    cidr_block ="0.0.0.0/0"
 gateway_id = aws_internet_gateway.name.id
}
}
resource "aws_route_table_association" "name" {
    subnet_id =aws_subnet.name.id
    route_table_id =aws_route_table.name.id
  
}
resource "aws_security_group" "name" {
  tags ={
    Name ="tej-sg"
  }
  description = "allow"
  vpc_id = aws_vpc.name.id

ingress{
    from_port=80
    to_port=80
    protocol ="tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
}
resource "aws_instance" "name" {
    ami="ami-0d0ad8bb301edb745"
    instance_type = "t3.medium"
      #vpc_id = aws_vpc.name.id
      subnet_id = aws_subnet.name.id
      vpc_security_group_ids =[aws_security_group.name.id]
      tags ={
        Name = "tej-Instance"
      }
}