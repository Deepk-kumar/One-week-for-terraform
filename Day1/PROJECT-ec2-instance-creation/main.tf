# Specify the provider block to define the AWS provider and the desired region
provider "aws" {
    region = "us-east-1"  # Set your desired AWS region here
}

# Define an AWS instance resource named "example"
resource "aws_instance" "example" {
    ami           = "ami-080e1f13689e07408"  # Specify an appropriate AMI ID for your region and requirements
    instance_type = "t2.micro"  # Specify the instance type for your EC2 instance (e.g., t2.micro, t3.micro, etc.)
}
