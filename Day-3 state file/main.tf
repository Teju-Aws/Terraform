provider "aws" {
  region = "ap-south-1"
}

# 1️⃣ Create IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "EC2FullAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 2️⃣ Attach EC2 Full Access Policy
resource "aws_iam_role_policy_attachment" "ec2_full_access_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# 3️⃣ Create Instance Profile for the Role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2FullAccessProfile"
  role = aws_iam_role.ec2_role.name
}

# 4️⃣ Update Existing EC2 Instance with IAM Role (⚠ Will Recreate)
resource "aws_instance" "name" {
  ami                  = "ami-0d0ad8bb301edb745"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "server"
  }
}
