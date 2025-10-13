output "vpc_id" {
  value = aws_vpc.main.id
}

output "backend_ecr_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "backend_service_name" {
  value = aws_ecs_service.backend_service.name
}

output "frontend_service_name" {
  value = aws_ecs_service.frontend_service.name
}
