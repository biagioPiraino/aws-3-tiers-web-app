# Create an internal VPC that span across different AZs 
# with public and private subnets to host the instances and the db
module "vpc" {
  source          = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git"
  name            = "internal-vpc"
  cidr            = "10.0.0.0/16"
  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]
  database_subnets  = ["10.0.21.0/24", "10.0.22.0/24"]
  enable_dns_hostnames = true
}

# Create a VPC endpoint for the S3 bucket
resource "aws_vpc_endpoint" "s3-vpc-endpoint" {
  vpc_endpoint_type = "Gateway"
  vpc_id = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region_deployment}.s3"
}