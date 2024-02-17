terraform {
  backend "s3" {
    bucket = "aws-cloud-sudeep-s3"
    key    = "rds/terraform.tfstate"
    region = "us-east-1"
  }
}