resource "aws_ecr_repository" "main" {
  name                 = "${var.name_prefix}-repository"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "docker_push" {
  depends_on = [aws_ecr_repository.main]

  triggers = {
    file_content_md5 = md5(file(var.dockerfile_path))
  }

  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  }
  provisioner "local-exec" {
    command = "docker build -t ${var.name_prefix} -f ${var.dockerfile_path} ."
  }
  provisioner "local-exec" {
    command = "docker tag ${var.name_prefix}:latest ${aws_ecr_repository.main.repository_url}:${var.image_tag}"
  }
  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.main.repository_url}:${var.image_tag}"
  }
}
