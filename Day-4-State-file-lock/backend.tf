terraform {
  backend "s3" {
    bucket         = "terraform-bucket-111111111"   # S3 bucket name
    key            = "Day-4/terraform.tfstate"       # Path to store state file
    region         = "ap-south-1"                  # AWS region
            # Optional for locking
    encrypt        = true                          # Encrypt state at rest
  }
}
