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
  region = "us-east-2" # Change if using a different region
}

############################################################
# 3. Security Group Configuration
############################################################

resource "aws_security_group" "app_sg" {
  vpc_id = "vpc-01c88a4ca8066e461" # Update with your VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH from anywhere (use more restrictive CIDR for production)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTPS from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # All outbound traffic
  }

  tags = {
    Name = "App Security Group"
  }
}

############################################################
# 4. EC2 Instance with User Data
############################################################

resource "aws_instance" "app" {
  ami                         = "ami-0d7ae6a161c5c4239"  # Update to a valid Amazon Linux 2 AMI in your region
  instance_type               = "t2.micro"
  key_name                    = "ec2_key"               # Must exist in your AWS account
  subnet_id                   = "subnet-0039d26229daad47a" # Update with a valid subnet ID
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true  # Ensures the instance has a public IP

  tags = {
    Name = "heroes-angular-app"
  }

  # EC2 User Data script runs on first boot
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system and install Docker
    sudo dnf update -y
    sudo dnf install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user

    # Pull the latest Docker image
    sudo docker pull halludbam/angular-heroes-app:latest

    # Gracefully stop and remove existing container (if any)
    EXISTING_CONTAINER=$(sudo docker ps -q -f name=angular-heroes-app)
    if [ ! -z "$EXISTING_CONTAINER" ]; then
      sudo docker stop $EXISTING_CONTAINER
      sudo docker rm $EXISTING_CONTAINER
    fi

    # Run the new container
    sudo docker run -d --name angular-heroes-app -p 80:80 halludbam/angular-heroes-app:latest
  EOF

  # Allow Terraform to SSH into the instance if needed
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.EC2_PRIVATE_KEY
    host        = self.public_ip
  }
}

############################################################
# 5. Outputs
############################################################

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.app.public_ip
}
