provider "aws" {
  region = "ap-south-1"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach CloudWatch logging permissions
resource "aws_iam_role_policy_attachment" "lambda_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "lambda_function" {
  function_name = "lambda-function"

  s3_bucket = "lambda-buckket-1111"  # must exist already
  s3_key    = "lambda.zip"           # zip must be uploaded

  runtime = "python3.12"
  handler = "lambda.lambda_handler"  # lambda.py → def lambda_handler(event, context)

  role = aws_iam_role.lambda_role.arn
}
