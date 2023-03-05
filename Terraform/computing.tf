###################
# INSTANCES       #
###################
resource "aws_instance" "web-tier" {
  availability_zone = data.aws_availability_zones.available.names[0]
  ami               = "ami-065793e81b1869261" # Amazon Linux 2
  instance_type     = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.allow-all-http-traffic.id,
  aws_security_group.allow-ssh-traffic.id]
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = aws_key_pair.public-key-pair.key_name
}

resource "aws_instance" "app-tier" {
  availability_zone = data.aws_availability_zones.available.names[0]
  ami               = "ami-065793e81b1869261" # Amazon Linux 2
  instance_type     = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.allow-http-traffic-from-public-instance.id,
  aws_security_group.allow-pinging.id]
  associate_public_ip_address = false
  subnet_id                   = module.vpc.private_subnets[0]
}

###################
# KEY PAIR        #
###################
resource "aws_key_pair" "public-key-pair" {
  key_name = "public-key-pair"
  public_key = "" # Insert your generated SSH key
}

###################
# SECURITY GROUPS #
###################

# Create a security group that allow all HTTP traffic 
# (this will be attached to the public instance)
resource "aws_security_group" "allow-all-http-traffic" {
  name   = "allow-all-http-traffic"
  vpc_id = module.vpc.vpc_id
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all HTTP traffic at port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
}

# Create a security group that allow HTTP traffic from the public instance
resource "aws_security_group" "allow-http-traffic-from-public-instance" {
  name   = "allow-http-traffic-from-public-instance"
  vpc_id = module.vpc.vpc_id
  ingress = [{
    cidr_blocks      = []
    description      = "Allow HTTP traffic from public instance"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = [aws_security_group.allow-all-http-traffic.id]
    self             = false
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
}

# Create a security group that allow SSH traffic from port 22 
# (this will be attached to the public instance)
resource "aws_security_group" "allow-ssh-traffic" {
  name   = "allow-ssh-traffic-from-alb"
  vpc_id = module.vpc.vpc_id
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow SSH traffic at port 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
}

# Create a security group that allow pinging from all ports 
# This will be attached to the private instance and pinging
# will be allowed only from the public instance 
resource "aws_security_group" "allow-pinging" {
  name   = "allow-pinging"
  vpc_id = module.vpc.vpc_id
  ingress = [{
    cidr_blocks      = []
    description      = "Allow pinging from public instance"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = [aws_security_group.allow-all-http-traffic.id]
    self             = false
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
}