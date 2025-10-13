variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "student-management-app"
}

variable "backend_port" {
  description = "Port for backend container"
  type        = number
  default     = 5000
}

variable "frontend_port" {
  description = "Port for frontend container"
  type        = number
  default     = 3000
}
