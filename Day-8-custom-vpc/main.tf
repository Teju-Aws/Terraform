provider "aws" {
  region = "ap-south-1"   # change if needed
}

module "day-8-custom-vpc" {
  source = "./day-8-vpc-modules"   # path to your custom module folder

  # VPC settings
  create_vpc = true
  name       = "tej-vpc"
  cidr       = "10.0.0.0/16"
  azs        = ["ap-south-1a", "ap-south-1b"]

  # Subnets
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24", "10.0.3.0/24"]

  # Security Groups
  sg_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # EC2
  create_ec2             = true
  ec2_ami                = "ami-0d0ad8bb301edb745"   # Amazon Linux 2 AMI (example for ap-south-1)
  ec2_instance_type      = "t2.micro"
  ec2_key_name           = "Tejuaws.pem"                  # replace with your key pair
  ec2_subnet_id          = aws_subnet.public[0].id
           # replace with real subnet ID (or output from module if chaining)
  ec2_security_group_ids = []                        # can pass sg IDs or rely on sg created above
  ec2_tags = {
    Project = "Day-8"
  }

  # RDS
  create_rds              = true
  rds_identifier          = "tej-rds"
  rds_engine              = "mysql"
  rds_engine_version      = "8.0"
  rds_instance_class      = "db.t2.micro"
  rds_username            = "admin"
  rds_password            = "Teju1234"            # ⚠️ don’t hardcode in production!
  rds_allocated_storage   = 20
  rds_subnet_ids          = ["subnet-aaaa1111", "subnet-bbbb2222"] # private subnets
  rds_security_group_ids  = []   # can pass SG IDs
  rds_publicly_accessible = false
  rds_multi_az            = false

  # Frontend Load Balancer
  create_fe_lb            = true
  fe_lb_name              = "FE-LB"
  fe_lb_type              = "application"
  fe_lb_internal          = false
  fe_lb_subnets           = ["subnet-aaaa1111", "subnet-bbbb2222"] # public subnets
  fe_lb_security_groups   = []
  fe_target_group_name    = "frontend-tg"
  fe_target_group_port    = 80
  fe_target_group_protocol= "HTTP"
  fe_listener_port        = 80

  # Backend Load Balancer
  create_be_lb            = true
  be_lb_name              = "BE-LB"
  be_lb_type              = "application"
  be_lb_internal          = true
  be_lb_subnets           = ["subnet-cccc3333", "subnet-dddd4444"] # private subnets
  be_lb_security_groups   = []
  be_target_group_name    = "backend-tg"
  be_target_group_port    = 3000
  be_target_group_protocol= "HTTP"
  be_listener_port        = 8080
}
