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
  region = "us-east-2" # Change if you're using another region
}

############################################################
# 3. EC2 Instance Using Existing Security Group
############################################################

resource "aws_instance" "app" {
  ami                         = "ami-0d7ae6a161c5c4239"   # Example Amazon Linux 2 AMI in us-east-2
  instance_type               = "t2.micro"
  key_name                    = "ec2_key"                # Must exist in your AWS account
  subnet_id                   = "subnet-0039d26229daad47a" # Replace with your subnet ID
  vpc_security_group_ids      = ["sg-05c19d32506b81d7c"]   # Use the existing SG here
  associate_public_ip_address = true

  tags = {
    Name = "heroes-angular-app"
  }

  # EC2 User Data script runs on first boot
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update the system and install Docker
    sudo dnf update -y
    sudo dnf install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user

    # Pull the latest Docker image (from Docker Hub)
    sudo docker pull halludbam/angular-heroes-app:latest

    # Stop and remove existing container (if any)
    EXISTING_CONTAINER=$(sudo docker ps -q -f name=angular-heroes-app)
    if [ ! -z "$EXISTING_CONTAINER" ]; then
      sudo docker stop $EXISTING_CONTAINER
      sudo docker rm $EXISTING_CONTAINER
    fi

    # Run the new container
    sudo docker run -d --name angular-heroes-app -p 80:80 halludbam/angular-heroes-app:latest
  EOF

  # Optional SSH access via Terraform
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.EC2_PRIVATE_KEY
    host        = self.public_ip
  }
}

############################################################
# 4. Outputs
############################################################

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.app.public_ip
}
