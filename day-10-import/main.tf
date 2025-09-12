
resource "aws_iam_user" "iam_user" {
  name ="Teju-user"
tags = {
    Name="Tejus-user"
}
}
resource "aws_iam_user_policy_attachment" "ec2_full_access" {
  user       = aws_iam_user.iam_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}