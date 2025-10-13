provider "aws" {
  region = var.aws_region
}

# ---------- VPC ----------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.app_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.app_name}-subnet-${count.index}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.app_name}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "${var.app_name}-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------- Security Group ----------
resource "aws_security_group" "ecs_sg" {
  name   = "${var.app_name}-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.app_name}-sg" }
}

# ---------- IAM Role for ECS Task Execution ----------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------- ECR ----------
resource "aws_ecr_repository" "backend" {
  name = "${var.app_name}-backend"
}

resource "aws_ecr_repository" "frontend" {
  name = "${var.app_name}-frontend"
}

# ---------- ECS Cluster ----------
resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-cluster"
}

# ---------- ECS Task Definition Backend ----------
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.app_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = aws_ecr_repository.backend.repository_url
      essential = true
      portMappings = [
        {
          containerPort = var.backend_port
          hostPort      = var.backend_port
        }
      ]
    }
  ])
}

# ---------- ECS Task Definition Frontend ----------
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.app_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = aws_ecr_repository.frontend.repository_url
      essential = true
      portMappings = [
        {
          containerPort = var.frontend_port
          hostPort      = var.frontend_port
        }
      ]
    }
  ])
}

# ---------- ECS Services ----------
resource "aws_ecs_service" "backend_service" {
  name            = "${var.app_name}-backend-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "frontend_service" {
  name            = "${var.app_name}-frontend-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
