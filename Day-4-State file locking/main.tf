resource "aws_instance" "name" {
  ami ="ami-0d54604676873b4ec"
  instance_type="t2.medium"
tags ={
    Name ="Server-2"
}


}
