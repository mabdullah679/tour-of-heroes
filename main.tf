############################################################
# 1. Variables
############################################################

variable "EC2_PRIVATE_KEY" {
  description = "The private key to access the EC2 instance via SSH."
  type        = string
  sensitive   = true
}

variable "commit_sha" {
  description = "The commit SHA used to trigger a Docker image refresh."
  type        = string
}

############################################################
# 2. AWS Provider Configuration
############################################################

provider "aws" {
  region = "us-east-2" # Update this if you are using a different region
}

############################################################
# 3. Subnet Configuration
############################################################

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "vpc-01c88a4ca8066e461" # Your VPC ID
  cidr_block              = "172.31.0.0/20"        # Your subnet CIDR
  map_public_ip_on_launch = true                   # Ensure public IP for instances
  availability_zone       = "us-east-2a"

  tags = {
    Name = "Public Subnet"
  }
}

############################################################
# 4. Security Group Configuration
############################################################

# Security Group for EC2
resource "aws_security_group" "app_sg" {
  vpc_id = "vpc-01c88a4ca8066e461" # Your VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere; restrict this as needed
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "App Security Group"
  }
}

############################################################
# 5. EC2 Instance with User Data
############################################################

resource "aws_instance" "app" {
  ami                         = "ami-0d7ae6a161c5c4239" # Example Amazon Linux 2 AMI
  instance_type               = "t2.micro"
  key_name                    = "ec2_key"               # Must exist in AWS
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true                    # Ensure public IP is assigned

  tags = {
    Name = "heroes-angular-app"
  }

  # EC2 User Data for initialization
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update the system and install Docker
    sudo dnf update -y
    sudo dnf install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user

    # Pull the latest Docker image
    sudo docker pull halludbam/angular-heroes-app:latest

    # Gracefully stop and remove the existing container, if it exists
    EXISTING_CONTAINER=$(sudo docker ps -q -f name=angular-heroes-app)
    if [ ! -z "$EXISTING_CONTAINER" ]; then
      sudo docker stop $EXISTING_CONTAINER
      sudo docker rm $EXISTING_CONTAINER
    fi

    # Run the new container
    sudo docker run -d --name angular-heroes-app -p 80:80 halludbam/angular-heroes-app:latest
  EOF

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.EC2_PRIVATE_KEY
    host        = self.public_ip
  }
}

############################################################
# 6. Outputs
############################################################

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.app.public_ip
}
