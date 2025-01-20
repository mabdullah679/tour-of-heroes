############################################################
# Variables
############################################################

# Private key for EC2 SSH access
variable "EC2_PRIVATE_KEY" {
  description = "The private key to access the EC2 instance via SSH."
  type        = string
  sensitive   = true
}

# Commit SHA for triggering Docker refresh
variable "commit_sha" {
  description = "The commit SHA used to trigger a Docker image refresh."
  type        = string
}

resource "null_resource" "wait_for_instance" {
  depends_on = [aws_instance.app]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "null_resource" "docker_refresh" {
  depends_on = [null_resource.wait_for_instance]

  triggers = {
    build_sha = var.commit_sha
  }

  provisioner "remote-exec" {
    inline = [
      # Pull the latest Docker image
      "sudo docker pull halludbam/angular-heroes-app:latest",

      # Gracefully stop and remove the existing container if it exists
      "EXISTING_CONTAINER=$(sudo docker ps -q -f name=angular-heroes-app) && if [ ! -z \"$EXISTING_CONTAINER\" ]; then sudo docker stop $EXISTING_CONTAINER && sudo docker rm $EXISTING_CONTAINER; fi",

      # Run the new container with proper volumes and port mapping
      "sudo docker run -d --name angular-heroes-app -p 80:80 halludbam/angular-heroes-app:latest",

      # Ensure Nginx reloads to apply any updated configurations
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