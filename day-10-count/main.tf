resource "aws_instance" "name" {
    ami ="ami-0e86e20dae9224db8"
    instance_type="t2.micro"
    count=length(var.ec2)
    tags={
        Name=var.ec2[count.index]
    }
}