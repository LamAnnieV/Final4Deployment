# ECS Cluster
resource "aws_ecs_cluster" "final4cluster" {
  name = "final4cluster"
  tags = {
    Name = "final4cluster"
  }
}

resource "aws_cloudwatch_log_group" "F4logs" {
  name = "/ecs/F4-logs"

  tags = {
    Application = "F4logs"
  }
}

# ECS Task Definition for BACKEND
resource "aws_ecs_task_definition" "aws-ecs-api-task" {
  family                   = "api-task"
  container_definitions   = <<EOF
[
  {
    "name": "api-container",
    "image": "dannydee93/eshoppublicapi:latest",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/F4logs",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "containerPort": 443,
          "hostPort": 443
      }
    ]
  }
]
EOF
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = "arn:aws:iam::848991144892:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::848991144892:role/ecsTaskExecutionRole"
}

# ECS Service for BACKEND
resource "aws_ecs_service" "aws-ecs-api-service" {
  name                 = "api-service"
  cluster              = aws_ecs_cluster.final4cluster.id
  task_definition      = aws_ecs_task_definition.aws-ecs-api-task.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 3
  force_new_deployment = true
  network_configuration {
    subnets            = [
      aws_subnet.privateA.id,
      aws_subnet.privateB.id,
      aws_subnet.privateC.id
    ]
    assign_public_ip   = false
    security_groups    = [aws_security_group.backend_sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "api-container"
    container_port   = 443
  }
}

# ECS Task Definition for FRONTEND
resource "aws_ecs_task_definition" "aws-ecs-web-task" {
  family                   = "web-task"
  container_definitions   = <<EOF
[
  {
    "name": "web-container",
    "image": "dannydee93/eshopwebmvc:latest",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/F4logs",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "containerPort": 80
      }
    ]
  }
]
EOF
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = "arn:aws:iam::848991144892:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::848991144892:role/ecsTaskExecutionRole"
}

# ECS Service for FRONTEND
resource "aws_ecs_service" "aws-ecs-web-service" {
  name                 = "web-service"
  cluster              = aws_ecs_cluster.final4cluster.id
  task_definition      = aws_ecs_task_definition.aws-ecs-web-task.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 3
  force_new_deployment = true
  network_configuration {
    subnets            = [
      aws_subnet.publicA.id,
      aws_subnet.publicB.id,
      aws_subnet.publicC.id
    ]
    assign_public_ip   = true
    security_groups    = [aws_security_group.frontend_sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "web-container"
    container_port   = 80
  }
}

# Security Group for Backend Service
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Security group for backend service"
  vpc_id      = aws_vpc.final4_vpc.id  # Replace with your VPC ID

  # Ingress rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add egress rules and tags
}

# Security Group for Frontend Service
resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Security group for frontend service"
  vpc_id      = aws_vpc.final4_vpc.id  # Replace with your VPC ID

  # Ingress rules (same as backend)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add egress rules and tags
}

