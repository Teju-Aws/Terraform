resource "aws_vpc" "name" {
  cidr_block = "var.cidr_block"
  tags ={
    Name ="Tej-vpc"
  }
}
resource "aws_subnet" "name" {
  vpc_id= "aws_vpc_id.name.id"
  cidr_block = "var.subnet_cidr"
  availability_zone = "var.az"
}