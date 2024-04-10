# Retrieve VPC outputs directly from the local state file
data "terraform_remote_state" "vpc" {
  backend = "local"
   
  config = {
    path = "/home/deepak/Downloads/One-week-for-terraform/Day2/vpc/terraform.tfstate" # Path to the Terraform state file of the VPC
  }
}

# Create a security group for the web servers
resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

locals {
  instance_type = var.instance
  ami_id        = var.ami_map
}

resource "aws_instance" "webserver1" {
  ami                    = var.ami_map
  instance_type          = var.instance
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  user_data              = base64encode(file("userdata.sh"))
}

#create alb
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.webSg.id]
  subnets         = [data.terraform_remote_state.vpc.outputs.public_subnet_ids[0], data.terraform_remote_state.vpc.outputs.public_subnet_ids[1]]

  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}