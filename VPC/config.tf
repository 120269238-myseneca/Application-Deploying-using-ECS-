terraform {
  backend "s3" {
    bucket = "aws-cloud-sudeep-s3"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}