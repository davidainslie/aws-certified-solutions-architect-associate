resource "aws_ecr_repository" "backwards-ecr" {
  name = "backwards-ecr"
}

# Retrieve an authentication token and authenticate your Docker client to your registry - Use the AWS CLI.

# aws ecr get-login
data "aws_ecr_authorization_token" "ecr-token" {}

resource "null_resource" "docker-login" {
  depends_on = [aws_ecr_repository.backwards-ecr]

  provisioner "local-exec" {
    # aws --profile <profile> ecr get-login-password --region <region> | docker login --username AWS --password-stdin <url>
    command = <<-EOT
      echo ${data.aws_ecr_authorization_token.ecr-token.password} | \
      docker login --username ${data.aws_ecr_authorization_token.ecr-token.user_name} --password-stdin ${data.aws_ecr_authorization_token.ecr-token.proxy_endpoint}
    EOT
  }
}

# Build your Docker image - After the build completes, tag your image so you can push the image to this repository
resource "null_resource" "docker-build" {
  depends_on = [null_resource.docker-login]

  provisioner "local-exec" {
    working_dir = "."

    command = <<-EOT
      docker build -t ${aws_ecr_repository.backwards-ecr.name} .
      docker tag ${aws_ecr_repository.backwards-ecr.name}:latest ${aws_ecr_repository.backwards-ecr.repository_url}:latest
    EOT
  }
}

# Run the following to push this image to your newly created AWS repository
resource "null_resource" "docker-push" {
  depends_on = [null_resource.docker-build]

  provisioner "local-exec" {
    command = <<-EOT
      docker push ${aws_ecr_repository.backwards-ecr.repository_url}:latest
    EOT
  }
}