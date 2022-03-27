output "repository_url" {
  value = aws_ecr_repository.main.repository_url
}

output "image_tag" {
  value = var.image_tag
}
