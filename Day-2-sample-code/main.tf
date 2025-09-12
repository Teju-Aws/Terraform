resource "aws_instance" "jen-server" {
    ami="ami-0b09ffb6d8b58ca91"
    instance_type="t2.medium"
    tags = { 
        Name = "jen-Server"
    }
  
}
