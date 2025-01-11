provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "app" {
  ami           = "ami-0d7ae6a161c5c4239"
  instance_type = "t2.micro"

  key_name = "ec2_key" # AWS-managed key pair

  vpc_security_group_ids = ["sg-05c19d32506b81d7c"]

  tags = {
    Name = "heroes-angular-app"
  }

  # Define the SSH connection details
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/ec2_key.pem")
    host        = self.public_ip
  }

  # Remote-exec provisioner to install Docker and run the app
    provisioner "remote-exec" {
        inline = [
            "sudo dnf update -y",
            "sudo dnf install -y docker",
            "sudo systemctl start docker",
            "sudo systemctl enable docker",
            "sudo docker pull halludbam/angular-heroes-app:latest", # Replace <your-tag> with the correct tag
            "sudo docker run -d -p 80:80 halludbam/angular-heroes-app:latest" # Ensure the correct tag is used
        ]
    }
}
