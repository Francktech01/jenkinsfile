# Define provider and backend configuration
provider "aws" {
  region = "us-east-2" # Change this to your desired AWS region
}

#create s3 bucket before running the script by running the command below before the script
#aws s3api create-bucket --bucket eksbucket32 --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2
terraform {
  backend "s3" {
    bucket  = "eksbucket32" # S3 bucket to store Terraform state
    key     = "jenkins.tfstate"
    region  = "us-east-2" # Region for the S3 bucket
    encrypt = true        # Optional, use DynamoDB for state locking
  }
}

# Define resources
resource "aws_s3_bucket_acl" "terraform_state_bucket" {
  bucket = "eksbucket32"
  acl    = "private"

}

# Create a new security group allowing SSH and Jenkins ports
resource "aws_security_group" "jenkins_security_group" {
  name        = "JenkinsSecurityGroup13"
  description = "Security group for Jenkins server"

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "jenkins_server" {
  ami           = "ami-09040d770ffe2224f" # Specify the AMI ID of your desired Jenkins server
  instance_type = "t2.medium"              # Change this to your desired instance type
  tags = {
    Name = "Jenkins_Server"
  }
}
resource "aws_instance" "server" {
    count = 2
  ami           = "ami-09040d770ffe2224f" # Specify the AMI ID of your desired Jenkins server
  instance_type = "t2.medium"              # Change this to your desired instance type
  tags = {
    Name = "Server-${count.index + 1}"
  }
  security_groups = [aws_security_group.jenkins_security_group.name]
  # Specify the key name for SSH access
  key_name = "jenkinskey"


  # Add any additional configuration as needed, such as security groups, subnet ID, etc.
}

