terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID where ECS will be deployed"
  type        = string
  # You'll need to replace this with your actual VPC ID
  default = "vpc-xxxxxxxxx"
}

variable "subnet_ids" {
  description = "Subnet IDs where ECS tasks will run"
  type        = list(string)
  # You'll need to replace these with your actual subnet IDs
  default = ["subnet-xxxxxxxxx", "subnet-yyyyyyyyy"]
}

# ECR Repositories for each microservice
resource "aws_ecr_repository" "apigateway" {
  name                 = "apigateway"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "bookingservice" {
  name                 = "bookingservice"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "inventoryservice" {
  name                 = "inventoryservice"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "orderservice" {
  name                 = "orderservice"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "microservices_cluster" {
  name = "microservices-${var.environment}"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_logs.name
      }
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/microservices-${var.environment}"
  retention_in_days = 7
}

# Security Group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-${var.environment}"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8081
    to_port     = 8081
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8082
    to_port     = 8082
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8083
    to_port     = 8083
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM role for ECS tasks
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Definition for API Gateway
resource "aws_ecs_task_definition" "apigateway" {
  family                   = "apigateway-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "apigateway"
      image     = "${aws_ecr_repository.apigateway.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "apigateway"
        }
      }
    }
  ])
}

# Task Definition for Booking Service
resource "aws_ecs_task_definition" "bookingservice" {
  family                   = "bookingservice-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "bookingservice"
      image     = "${aws_ecr_repository.bookingservice.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "bookingservice"
        }
      }
    }
  ])
}

# Task Definition for Inventory Service
resource "aws_ecs_task_definition" "inventoryservice" {
  family                   = "inventoryservice-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "inventoryservice"
      image     = "${aws_ecr_repository.inventoryservice.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8082
          hostPort      = 8082
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "inventoryservice"
        }
      }
    }
  ])
}

# Task Definition for Order Service
resource "aws_ecs_task_definition" "orderservice" {
  family                   = "orderservice-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "orderservice"
      image     = "${aws_ecr_repository.orderservice.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8083
          hostPort      = 8083
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "orderservice"
        }
      }
    }
  ])
}

# ECS Services
resource "aws_ecs_service" "apigateway" {
  name            = "apigateway-svc"
  cluster         = aws_ecs_cluster.microservices_cluster.id
  task_definition = aws_ecs_task_definition.apigateway.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "bookingservice" {
  name            = "bookingservice-svc"
  cluster         = aws_ecs_cluster.microservices_cluster.id
  task_definition = aws_ecs_task_definition.bookingservice.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "inventoryservice" {
  name            = "inventoryservice-svc"
  cluster         = aws_ecs_cluster.microservices_cluster.id
  task_definition = aws_ecs_task_definition.inventoryservice.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "orderservice" {
  name            = "orderservice-svc"
  cluster         = aws_ecs_cluster.microservices_cluster.id
  task_definition = aws_ecs_task_definition.orderservice.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }
}

# Outputs
output "ecr_repositories" {
  description = "ECR repository URLs"
  value = {
    apigateway       = aws_ecr_repository.apigateway.repository_url
    bookingservice   = aws_ecr_repository.bookingservice.repository_url
    inventoryservice = aws_ecr_repository.inventoryservice.repository_url
    orderservice     = aws_ecr_repository.orderservice.repository_url
  }
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.microservices_cluster.name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.microservices_cluster.arn
}
