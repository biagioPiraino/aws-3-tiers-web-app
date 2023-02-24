# Initialize terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.region_deployment
  access_key = "" # Add an access key
  secret_key = "" # Add a secret key
}

# Define the region of deployment
variable "region_deployment" {
  default = "eu-west-1"
}

# Declare availability zones data source
data "aws_availability_zones" "available" {
  state = "available"
}