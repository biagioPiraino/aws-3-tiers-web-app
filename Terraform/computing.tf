# Create an ALB that will operate in the vpc's public subnet
resource "aws_lb" "alb" {
	name = "application-load-balancer"
	internal = false
	load_balancer_type = "application"
	subnets = [ for subnet in aws_subnet.public-subnet : subnet.id ]
	security_groups = [ aws_security_group.https-inbound-sg.id ]
}

# Create the security group that allow all https inbound traffic
# and that will be associated to the ALB
resource "aws_security_group" "https-inbound-sg" {
	name = "inbound-https-security-group"

	ingress = [ {
		cidr_blocks = [ "0.0.0.0/0" ]
		description = "Allow https traffic from everywhere"
		from_port = 443
		ipv6_cidr_blocks = []
		prefix_list_ids = []
		protocol = "HTTPS"
		security_groups = []
		self = false
		to_port = 443
	} ]

	egress = [ {
		cidr_blocks = [ "0.0.0.0/0" ]
		description = "Allow all the outbound traffic"
		from_port = 0
		ipv6_cidr_blocks = []
		prefix_list_ids = []
		protocol = "-1"
		security_groups = []
		self = false
		to_port = 0
	} ]

	vpc_id = aws_vpc.vpc.id
}

# Define the type of instances that will be part of the ALB target group
data "aws_ami" "tg-instance-type" {
	most_recent = true
	owners = [ "amazon" ]
	filter {
		name = "name" # check if relevant/mandatory, remove otherwise
		values = [ "amzn-ami-hvm-*-x86_64-ebs" ]
	}
}

# Define the launch configuration that will be used for the autoscaling group
resource "aws_launch_configuration" "asg-launch-configuration" {
	name_prefix = "asg-launch-configuration-"
	image_id = data.aws_ami.tg-instance-type.id
	instance_type = "t2.micro"
	security_groups = [ aws_security_group.alb-only-inbound-sg.id ]
	
	lifecycle {
		# This attribute is necessary if we change name or name_prefix properties
		# This attribute is also used in the Terraform example when used for ASGs
		create_before_destroy = true
	}
}

# Define the security group to allow inbound traffic to the EC2 only from the ALB
resource "aws_security_group" "alb-only-inbound-sg" {
	name = "alb-only-inbound-security-group"

	ingress = [ {
		cidr_blocks = []
		description = "Allow incoming traffic only from an ALB"
		from_port = 80
		ipv6_cidr_blocks = []
		prefix_list_ids = []
		protocol = "HTTP"
		security_groups = [ aws_security_group.https-inbound-sg.id ]
		self = false
		to_port = 80
	} ]

	egress = [ {
		cidr_blocks = []
		description = "Allow outbound traffic to reach the ALB only"
		from_port = 80
		ipv6_cidr_blocks = []
		prefix_list_ids = []
		protocol = "-1"
		security_groups = [ aws_security_group.https-inbound-sg.id ]
		self = false
		to_port = 80
	} ]

	vpc_id = aws_vpc.vpc.id
}

# Create the autoscaling group that will operate in private subnets
# across different availability zones as defined in the vpc.tf
resource "aws_autoscaling_group" "asg" {
	name = "auto-scaling-group"
	min_size = 1
	desired_capacity = 1
	max_size = 3
	launch_configuration = aws_launch_configuration.asg-launch-configuration.name
	vpc_zone_identifier = [ for subnet in aws_subnet.private-subnet : subnet.id ]
	
	tag {
		key   = "name"
		value = "auto-scaling-group"
		# Propagate tags to the EC2 instances created in the scaling process
		propagate_at_launch = true 
	}
}

# Create a target group for the ALB
resource "aws_lb_target_group" "alb-target-group" {
	name = "alb-target-group"
	port = 80
	protocol = "HTTP"
	vpc_id = aws_vpc.vpc.id	
}

# Create a listener to redirect ALB traffic to EC2 instances
resource "aws_lb_listener" "alb-asg-listener" {
	load_balancer_arn = aws_lb.alb.arn
	port = 80
	protocol = "HTTP"

	default_action {
		type = "forward"
		target_group_arn = aws_lb_target_group.alb-target-group.arn
	}
}

# Create an autoscaling group attachment to connect the ALB to the target group
resource "aws_autoscaling_attachment" "asg-attachment" {
	autoscaling_group_name = aws_autoscaling_group.asg.id
	lb_target_group_arn = aws_lb_target_group.alb-target-group.arn
}