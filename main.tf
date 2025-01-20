############################################################
# Variables
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
# AWS Provider Configuration
############################################################

provider "aws" {
  region = "us-east-2"
}

############################################################
# EC2 Instance
############################################################

resource "aws_instance" "app" {
  ami           = "ami-0d7ae6a161c5c4239" # Example Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "ec2_key"               # Must exist in AWS
  vpc_security_group_ids = ["sg-05c19d32506b81d7c"] # Your security group ID

  tags = {
    Name = "heroes-angular-app"
  }

  # Configure SSH connection to the instance
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.EC2_PRIVATE_KEY
    host        = self.public_ip
  }

  # Provision Docker on the EC2 instance
  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ec2-user" # Add the user to the Docker group
    ]
  }
}

############################################################
# Wait for EC2 Instance Initialization
############################################################

resource "null_resource" "wait_for_instance" {
  depends_on = [aws_instance.app]

  provisioner "local-exec" {
    command = "sleep 30" # Add delay to ensure instance is fully initialized
  }
}

############################################################
# Docker Refresh
############################################################

resource "null_resource" "docker_refresh" {
  depends_on = [null_resource.wait_for_instance]

  triggers = {
    # Re-provision when commit_sha changes
    build_sha = var.commit_sha
  }

  provisioner "remote-exec" {
    inline = [
      # Pull the latest Docker image
      "sudo docker pull halludbam/angular-heroes-app:latest",

      # Gracefully stop and remove existing container if it exists
      "EXISTING_CONTAINER=$(sudo docker ps -q -f name=angular-heroes-app) && if [ ! -z \"$EXISTING_CONTAINER\" ]; then sudo docker stop $EXISTING_CONTAINER && sudo docker rm $EXISTING_CONTAINER; fi",

      # Run the new container with proper ports
      "sudo docker run -d --name angular-heroes-app -p 80:80 halludbam/angular-heroes-app:latest",

      # Reload Nginx configuration
      "sudo docker exec angular-heroes-app nginx -s reload"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.EC2_PRIVATE_KEY
      host        = aws_instance.app.public_ip
    }
  }
}

############################################################
# Outputs
############################################################

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.app.public_ip
}

############################################################
# Notes
############################################################
# 1. Your security group ID ("sg-05c19d32506b81d7c") is correctly included.
# 2. Ensure "ec2_key" exists in AWS and matches your private key.
# 3. Pass variables via -var flags or a terraform.tfvars file.
# 4. Use `terraform fmt` to format and validate this file.
