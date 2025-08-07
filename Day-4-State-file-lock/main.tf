resource "aws_instance" "name" {
    ami="ami-0d0ad8bb301edb745"
    instance_type="t2.micro"
    tags = { 
        Name = "My-Server"
    }
  
}
resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16" 
       tags = {
         Name = "Tej-vpc"    
       }
}