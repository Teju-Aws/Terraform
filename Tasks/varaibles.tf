variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "EC2 Key Pair Name"
  default     = "Tejuaws.pem"
}

variable "db_password" {
  description = "Password for RDS mySQL"
  type        = string
  sensitive   = true
}
