# Create a VPC
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
}

# Create an Internet Gateway to allow public traffic 
# inside the VPC
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id
}

# Create a public subnet where the ALB will operate
# The Alb will operate cross-AZ thanks to the 
# cross-zone load balancing feature enabled by default
resource "aws_subnet" "public-subnet" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = true
}

# Create 3 private subnets that will contain the EC2 instances
# part of the ALB target group
resource "aws_subnet" "private-subnet" {
  count = 3
  availability_zone = data.aws_availability_zones.available.names[count.index]
   # To avoid overlapping the blocks with the public subnet
  cidr_block = "10.0.${count.index + 2}.0/24"
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
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.vpc-route-table.id
}