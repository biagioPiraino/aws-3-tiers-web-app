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
  count = 3
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = "10.0.${count.index}.0/24"
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = true
}

# Create three private subnets that will contain the EC2 instances
# part of the ALB target group
resource "aws_subnet" "private-subnet" {
  count = 3
  availability_zone = data.aws_availability_zones.available.names[count.index]
   # To avoid overlapping the blocks with the public subnet
  cidr_block = "10.0.${count.index + 3}.0/24"
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = false
}

# Create a route table that will be used to redirect internet 
# traffic to public subnets
resource "aws_route_table" "vpc-route-table" {
  vpc_id = aws_vpc.vpc.id
  route = [ {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
    carrier_gateway_id = ""
    core_network_arn = ""
    destination_prefix_list_id = ""
    egress_only_gateway_id = ""
    instance_id = ""
    ipv6_cidr_block = ""
    local_gateway_id = ""
    nat_gateway_id = ""
    network_interface_id = ""
    transit_gateway_id = ""
    vpc_endpoint_id = ""
    vpc_peering_connection_id = ""
  } ]
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "public-subnet-association" {
  count = 3
  subnet_id = aws_subnet.public-subnet.*.id[count.index]
  route_table_id = aws_route_table.vpc-route-table.id
}

# Create a VPC endpoint for the S3 bucket
resource "aws_vpc_endpoint" "s3-vpc-endpoint" {
  vpc_endpoint_type = "Gateway"
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region_deployment}.s3"
}