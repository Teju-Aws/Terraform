resource "aws_instance" "ec2" {
  ami="ami-00ca32bbc84273381"
  instance_type = "t2.micro"
  for_each = toset(var.ec2)
  tags={
    Name=each.value
  }

}
variable "ec2"{
    type=list(string)
    default=["dev1","prod1"]
}