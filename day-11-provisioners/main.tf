
resource "aws_key_pair" "tej"{
    key_name="tej"
    public_key=file("C:/Users/vaas1/.ssh/id_rsa_tf.pub")

}
resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  tags ={
    Name ="tej-vpc"
  }
}
resource "aws_subnet" "name" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    tags={
        Name="tej_sub"
    }
}
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.name.id
  
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.name.id
route {
    cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}
}
resource "aws_route_table_association" "name" {
  
  subnet_id = aws_subnet.name.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.name.id
  description = "allow"
  ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
   from_port = 0
   to_port = 0
   protocol = -1
   cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "name" {
  ami="ami-00ca32bbc84273381"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.name.id
  key_name = aws_key_pair.tej.key_name
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags={
    Name="Tej"
  }

connection{
    type="ssh"
    user="ec2-user"
    private_key=file("C:/Users/vaas1/.ssh/id_rsa_tf")
    host=self.public_ip
    timeout="2m"

}
provisioner "file"{
    source="file10"
    destination="/home/ec2-user/file10"
}
provisioner "remote-exec"{
    inline=[
        "touch file200",
        "echo 'hello teju' >>/home/ec2-user/file200"
    ]
}
provisioner "local-exec"{
    command = "echo hello teju from local >> file500"
}
}
resource "null_resource" "name"{
provisioner "local-exec"{
    command = "echo hello teju from local >> file500"
}
triggers ={
  always_run= timestamp()
}
}

