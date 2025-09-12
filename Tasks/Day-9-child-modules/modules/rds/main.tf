resource "aws_db_subnet_group" "db-sbnet-group" {
  name="db-subnet-group"
subnet_ids = [var.subnet_id]
tags={
    Name="db_subnet_group"
}
}
resource "aws_db_instance" "name" {
  engine = "mysql"
  engine_version = "8.0"
  allocated_storage = 20
  instance_class = var.instance_class
  db_name = var.db_name
   username=var.db_username
  password=var.db_password
  db_subnet_group_name = aws_db_subnet_group.db-sbnet-group.name
  skip_final_snapshot = true

}