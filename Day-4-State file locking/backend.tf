# backend.tf
terraform {
  backend "s3" {
    bucket         = "terraform-bucket-111111111"  # Use your S3 bucket name
    key            = "Day-4/terraform.tfstate"  # Any path you prefer
    region         = "ap-south-1"
    #dynamodb_table = "dynamo-lock-table"
    encrypt        = true
    #use_lockfile =  true
  }
}
