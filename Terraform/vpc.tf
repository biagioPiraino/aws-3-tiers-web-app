# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create an Internet Gateway to allow public traffic 
# inside the VPC
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id
}

# Create three public subnets where the ALB will operate
# The Alb will operate cross-AZ thanks to the 
# cross-zone load balancing feature enabled by default
# Rememeber that for an ALB to function, we should select
# at least two subnets in different availability  zones
resource "aws_subnet" "public-subnet" {
  count                   = 3
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
}

# Create three private subnets that will contain the EC2 instances
# part of the ALB target group
resource "aws_subnet" "private-subnet" {
  count             = 3
  availability_zone = data.aws_availability_zones.available.names[count.index]
  # To avoid overlapping the blocks with the public subnet
  cidr_block              = "10.0.${count.index + 3}.0/24"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false
}

# Create a route table that will be used to redirect internet 
# traffic to public subnets
resource "aws_route_table" "vpc-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "public-subnet-association" {
  count          = 3
  subnet_id      = aws_subnet.public-subnet.*.id[count.index]
  route_table_id = aws_route_table.vpc-route-table.id
}

# Create a VPC endpoint for the S3 bucket
resource "aws_vpc_endpoint" "s3-vpc-endpoint" {
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region_deployment}.s3"
}

# Create a route table to route traffic from private subnet to the endpoint
resource "aws_route_table" "s3-vpc-endpoint-private-routing" {
  vpc_id = aws_vpc.vpc.id
}

# Create a vpc endpoint route table association to associate the private 
# routing table with the endpoint
resource "aws_vpc_endpoint_route_table_association" "s3-vpc-endpoint-routing-association" {
  route_table_id  = aws_route_table.s3-vpc-endpoint-private-routing.id
  vpc_endpoint_id = aws_vpc_endpoint.s3-vpc-endpoint.id
}

# Create a vpc endpoint's policy to allow only certain kind of operations
# towards the s3 target bucket
resource "aws_vpc_endpoint_policy" "s3-vpc-endpoint-policy" {
  vpc_endpoint_id = aws_vpc_endpoint.s3-vpc-endpoint.id
  policy          = data.aws_iam_policy_document.access-to-specific-bucket.json
}

# Create a policy document
data "aws_iam_policy_document" "access-to-specific-bucket" {
  # Allow only certain kind of operations to be performed 
  # on a specific s3 bucket
  statement {
    sid = "AccessSpecificBucket"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    "s3:PutObject"]
    resources = [
      aws_s3_bucket.s3-storage.arn,
      "${aws_s3_bucket.s3-storage.arn}/*"
    ]
  }
}

# Create 2 private subnets for the DB instance
resource "aws_subnet" "db-private-subnet" {
  count             = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]
  # To avoid overlapping the blocks with other subnets
  cidr_block              = "10.0.${count.index + 6}.0/24"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false
}

# Create a routing table for the private db subnets
resource "aws_route_table" "db-private-routing" {
  vpc_id = aws_vpc.vpc.id
}

# And associate the db private subnet with it
resource "aws_route_table_association" "db-private-routing-association" {
  count          = 2
  route_table_id = aws_route_table.db-private-routing.id
  subnet_id      = aws_subnet.db-private-subnet.*.id[count.index]
}

# Create a specific public subnet for the NAT Gateway
resource "aws_subnet" "nat-gateway-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.8.0/24"
  map_public_ip_on_launch = true
}

# Create a NAT gateway to allow SSH access to private EC2s
resource "aws_eip" "nat-gateway-eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-gateway-eip.id
  subnet_id     = aws_subnet.nat-gateway-subnet.id
}

# Update the VPC route table to include the NAT Gateway routing
resource "aws_route_table" "nat-gateway-routing" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }
}

resource "aws_route_table_association" "nat-gateway-routing-association" {
  route_table_id = aws_route_table.nat-gateway-routing
  subnet_id      = aws_subnet.nat-gateway-subnet.id
}