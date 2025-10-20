# This is a reference implementation for production deployment
# Backend Infrastructure - ECS/Fargate
# This file defines all backend-related AWS resources for the Tracksuit application

# ECS Cluster
resource "aws_ecs_cluster" "tracksuit" {
  name = "tracksuit-prod"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = "production"
    Service     = "tracksuit"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "tracksuit_backend" {
  name              = "/ecs/tracksuit-backend"
  retention_in_days = 30

  tags = {
    Environment = "production"
    Service     = "tracksuit-backend"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "tracksuit_backend" {
  family                   = "tracksuit-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "tracksuit-backend"
      image     = "saedabdu/tracksuit-backend:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SERVER_PORT"
          value = "8080"
        },
        {
          name  = "NODE_ENV"
          value = "production"
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.database_url.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.tracksuit_backend.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "backend"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:8080/_health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      mountPoints = [
        {
          sourceVolume  = "efs-storage"
          containerPath = "/app/tmp"
          readOnly      = false
        }
      ]
    }
  ])

  volume {
    name = "efs-storage"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.tracksuit_data.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049

      authorization_config {
        access_point_id = aws_efs_access_point.tracksuit_backend.id
        iam             = "ENABLED"
      }
    }
  }

  tags = {
    Environment = "production"
    Service     = "tracksuit-backend"
  }
}

# ECS Service
resource "aws_ecs_service" "tracksuit_backend" {
  name            = "tracksuit-backend"
  cluster         = aws_ecs_cluster.tracksuit.id
  task_definition = aws_ecs_task_definition.tracksuit_backend.arn
  desired_count   = 3
  launch_type     = "FARGATE"
  platform_version = "LATEST"

  deployment_configuration {
    deployment_circuit_breaker {
      enable   = true
      rollback = true
    }
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.tracksuit_backend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tracksuit_backend.arn
    container_name   = "tracksuit-backend"
    container_port   = 8080
  }

  health_check_grace_period_seconds = 60

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  tags = {
    Environment = "production"
    Service     = "tracksuit-backend"
  }

  # Uncomment if using the ALB listener resource above
  # depends_on = [aws_lb_listener.tracksuit]
}

# Application Load Balancer Target Group
resource "aws_lb_target_group" "tracksuit_backend" {
  name        = "tracksuit-backend"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/_health"
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = {
    Environment = "production"
    Service     = "tracksuit-backend"
  }
}

# Auto Scaling
resource "aws_appautoscaling_target" "tracksuit_backend" {
  max_capacity       = 10
  min_capacity       = 3
  resource_id        = "service/${aws_ecs_cluster.tracksuit.name}/${aws_ecs_service.tracksuit_backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "tracksuit_backend_cpu" {
  name               = "tracksuit-backend-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.tracksuit_backend.resource_id
  scalable_dimension = aws_appautoscaling_target.tracksuit_backend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.tracksuit_backend.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# EFS File System for SQLite (or use RDS PostgreSQL in production)
resource "aws_efs_file_system" "tracksuit_data" {
  creation_token = "tracksuit-data"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name        = "tracksuit-data"
    Environment = "production"
  }
}

resource "aws_efs_access_point" "tracksuit_backend" {
  file_system_id = aws_efs_file_system.tracksuit_data.id

  posix_user {
    gid = 1001
    uid = 1001
  }

  root_directory {
    path = "/tracksuit"
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = "755"
    }
  }

  tags = {
    Name        = "tracksuit-backend-access-point"
    Environment = "production"
  }
}

# Security Group
resource "aws_security_group" "tracksuit_backend" {
  name        = "tracksuit-backend"
  description = "Security group for Tracksuit backend ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
    description     = "Allow traffic from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "tracksuit-backend"
    Environment = "production"
  }
}

# IAM Roles
resource "aws_iam_role" "ecs_execution_role" {
  name = "tracksuit-ecs-execution-role"

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

resource "aws_iam_role" "ecs_task_role" {
  name = "tracksuit-ecs-task-role"

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

# Secrets Manager - Database URL (placeholder)
resource "aws_secretsmanager_secret" "database_url" {
  name        = "tracksuit/database-url"
  description = "Database connection URL for Tracksuit backend"

  tags = {
    Environment = var.environment
    Service     = "tracksuit-backend"
  }
}

# ALB Listener (uncomment if you need to create a new listener)
# resource "aws_lb_listener" "tracksuit" {
#   load_balancer_arn = var.alb_arn
#   port              = "80"
#   protocol          = "HTTP"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tracksuit_backend.arn
#   }
# }

