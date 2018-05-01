provider "aws" {
  region  = "eu-central-1"
}

# Store state data on S3
terraform {
  backend "s3" {
    bucket  = "colognedemo-terraform-state"
    key     = "colognedemo.tfstate"
    region  = "eu-central-1"
  }
}
