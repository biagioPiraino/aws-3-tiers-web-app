###################
# INSTANCES       #
###################

resource "aws_instance" "web-tier" {
  availability_zone = data.aws_availability_zones.available.names[0]
  ami = "ami-065793e81b1869261" # Amazon Linux
  instance_type = "t2.micro"
  vpc_security_group_ids = [ 
    aws_security_group.allow-all-http-traffic.id,
    aws_security_group.allow-ssh-traffic.id]
  associate_public_ip_address = true
  subnet_id = module.vpc.public_subnets[0]
  key_name = aws_key_pair.public-key-pair.key_name
}

resource "aws_instance" "app-tier" {
  availability_zone = data.aws_availability_zones.available.names[0]
  ami = "ami-065793e81b1869261" # Amazon Linux
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.allow-http-traffic-from-public-instance.id,
    aws_security_group.allow-pinging.id]
  associate_public_ip_address = false
  subnet_id = module.vpc.private_subnets[0]
}

###################
# KEY PAIR        #
###################
resource "aws_key_pair" "public-key-pair" {
  key_name = "public-key-pair"
  # Insert your generated SSH key
  public_key = ""
}

###################
# SECURITY GROUPS #
###################

# Create a security group that allow all HTTP traffic 
# (this will be attached to the public instance)
resource "aws_security_group" "allow-all-http-traffic" {
  name = "allow-all-http-traffic"
  vpc_id = module.vpc.vpc_id
  ingress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow all HTTP traffic at port 80"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  } ]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  } ]
}

# Create a security group that allow HTTP traffic from the public instance
resource "aws_security_group" "allow-http-traffic-from-public-instance" {
  name = "allow-http-traffic-from-public-instance"
  vpc_id = module.vpc.vpc_id
  ingress = [ {
    cidr_blocks = []
    description = "Allow HTTP traffic from public instance"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = [aws_security_group.allow-all-http-traffic.id]
    self = false
  } ]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  } ]
}

# Create a security group that allow SSH traffic from port 22 
# (this will be attached to the public instance)
resource "aws_security_group" "allow-ssh-traffic" {
  name = "allow-ssh-traffic-from-alb"
  vpc_id = module.vpc.vpc_id
  ingress = [ {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH traffic at port 22"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  } ]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  } ]
}

# Create a security group that allow pinging from all ports 
# This will be attached to the private instance and pinging
# will be allowed only from the public instance 
resource "aws_security_group" "allow-pinging" {
  name = "allow-pinging"
  vpc_id = module.vpc.vpc_id
  ingress = [ {
    cidr_blocks = []
    description = "Allow pinging from public instance"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = [aws_security_group.allow-all-http-traffic.id]
    self = false
  } ]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  } ]
}




#############################################
# # Create an ALB that will operate in the vpc's public subnet
# resource "aws_lb" "alb" {
#   name               = "application-load-balancer"
#   internal           = false
#   load_balancer_type = "application"
#   subnets            = [for subnet in aws_subnet.public-subnet : subnet.id]
#   security_groups    = [aws_security_group.http-inbound-sg.id]
#   enable_cross_zone_load_balancing = true
# }

# # Create the security group that allow all http inbound traffic
# # and that will be associated to the ALB
# resource "aws_security_group" "http-inbound-sg" {
#   name = "inbound-http-security-group"

#   ingress = [{
#     cidr_blocks      = ["0.0.0.0/0"]
#     description      = "Allow http traffic from everywhere"
#     from_port        = 80
#     ipv6_cidr_blocks = []
#     prefix_list_ids  = []
#     protocol         = "tcp"
#     security_groups  = []
#     self             = false
#     to_port          = 80
#   }]

#   egress = [{
#     cidr_blocks      = ["0.0.0.0/0"]
#     description      = "Allow all the outbound traffic"
#     from_port        = 0
#     ipv6_cidr_blocks = []
#     prefix_list_ids  = []
#     protocol         = "-1"
#     security_groups  = []
#     self             = false
#     to_port          = 0
#   }]

#   vpc_id = aws_vpc.vpc.id
# }

# # Define the type of instances that will be part of the ALB target group
# data "aws_ami" "tg-instance-type" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter {
#     name   = "name"
#     values = ["amzn-ami-hvm-*-x86_64-ebs"]
#   }
# }

# # Define the launch configuration that will be used for the autoscaling group
# resource "aws_launch_configuration" "asg-launch-configuration" {
#   name_prefix     = "asg-launch-configuration-"
#   image_id        = data.aws_ami.tg-instance-type.id
#   instance_type   = "t2.micro"
#   security_groups = [aws_security_group.alb-only-inbound-sg.id]
#   user_data       = file("ec2-user-data.sh")

#   lifecycle {
#     # This attribute is necessary if we change name or name_prefix properties
#     # This attribute is also used in the Terraform example when used for ASGs
#     create_before_destroy = true
#   }
# }

# # Define the security group to allow inbound traffic to the EC2 only from the ALB
# resource "aws_security_group" "alb-only-inbound-sg" {
#   name = "alb-only-inbound-security-group"

#   ingress = [{
#     cidr_blocks      = []
#     description      = "Allow incoming traffic only from an ALB"
#     from_port        = 80
#     ipv6_cidr_blocks = []
#     prefix_list_ids  = []
#     protocol         = "tcp"
#     security_groups  = [aws_security_group.http-inbound-sg.id]
#     self             = false
#     to_port          = 80
#     }]

#   egress = [{
#     cidr_blocks      = []
#     description      = "Allow outbound traffic to reach the ALB only"
#     from_port        = 0
#     ipv6_cidr_blocks = []
#     prefix_list_ids  = []
#     protocol         = "-1"
#     security_groups  = [aws_security_group.http-inbound-sg.id]
#     self             = false
#     to_port          = 0
#   }]

#   vpc_id = aws_vpc.vpc.id
# }

# # Create the autoscaling group that will operate in private subnets
# # across different availability zones as defined in the vpc.tf
# resource "aws_autoscaling_group" "asg" {
#   name                 = "auto-scaling-group"
#   min_size             = 1
#   desired_capacity     = 1
#   max_size             = 3
#   launch_configuration = aws_launch_configuration.asg-launch-configuration.name
#   vpc_zone_identifier  = [for subnet in aws_subnet.private-subnet : subnet.id]

#   tag {
#     key   = "name"
#     value = "auto-scaling-group"
#     # Propagate tags to the EC2 instances created in the scaling process
#     propagate_at_launch = true
#   }
# }

# # Create a target group for the ALB
# resource "aws_lb_target_group" "alb-target-group" {
#   name     = "alb-target-group"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.vpc.id
# }

# # Create a listener to redirect ALB traffic to EC2 instances
# resource "aws_lb_listener" "alb-asg-listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.alb-target-group.arn
#   }
# }

# # Create an autoscaling group attachment to connect the ALB to the target group
# resource "aws_autoscaling_attachment" "asg-attachment" {
#   autoscaling_group_name = aws_autoscaling_group.asg.name
#   lb_target_group_arn    = aws_lb_target_group.alb-target-group.arn
# }