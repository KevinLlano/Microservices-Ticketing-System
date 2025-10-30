# Minimal AWS ECR + ECS Setup for Testing
# Cost-optimized for US East 1 (Virginia)

provider "aws" {
  region = "us-east-1"  # Cheapest region
}

# ECR Repository (only one service for minimal cost)
resource "aws_ecr_repository" "apigateway" {
  name                 = "microservices-apigateway"
  image_tag_mutability = "MUTABLE"

  # Disable expensive features
  image_scanning_configuration {
    scan_on_push = false  # Saves cost
  }
}

# Use Default VPC (no additional cost)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ECS Cluster (no cost for cluster itself)
resource "aws_ecs_cluster" "main" {
  name = "microservices-cluster"

  # Disable expensive monitoring
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# Security Group
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "ecs-tasks-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

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

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

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

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition - MINIMAL RESOURCES
resource "aws_ecs_task_definition" "apigateway" {
  family                   = "apigateway"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"    # Smallest possible
  memory                   = "512"    # Smallest possible
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "apigateway"
      image     = "${aws_ecr_repository.apigateway.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/apigateway"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "apigateway" {
  name              = "/ecs/apigateway"
  retention_in_days = 1  # Minimal retention to save cost
}

# ECS Service - MINIMAL SCALE
resource "aws_ecs_service" "apigateway" {
  name            = "apigateway-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.apigateway.arn
  desired_count   = 1     # Only 1 instance
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true  # For internet access without NAT Gateway cost
  }

  # Disable service discovery to save cost
  enable_execute_command = false
}

# Outputs
output "ecr_repository_url" {
  description = "ECR repository URL for pushing images"
  value       = aws_ecr_repository.apigateway.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "aws_region" {
  description = "AWS region"
  value       = "us-east-1"
}
