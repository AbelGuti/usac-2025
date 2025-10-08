# Configura el proveedor de AWS
provider "aws" {
  region = var.aws_region
}

# --- Recursos de Red y Seguridad ---

# Grupo de seguridad para el Application Load Balancer (ALB)
# Permite el tráfico entrante en el puerto 80 desde cualquier lugar (Internet)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-usac-demo"
  description = "Allow HTTP inbound traffic for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALBSecurityGroup"
  }
}

# Grupo de seguridad para el servicio de ECS
# Permite el tráfico entrante en el puerto 5000 solo desde el ALB
resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-sg-usac-demo"
  description = "Allow traffic from ALB to ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ECSServiceSecurityGroup"
  }
}


# --- Recursos del Application Load Balancer (ALB) ---

# Creación del ALB
resource "aws_lb" "main" {
  name               = "usac-demo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  tags = {
    Name = "UsacDemoALB"
  }
}

# Creación del Target Group para el ALB
resource "aws_lb_target_group" "main" {
  name        = "usac-demo-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "UsacDemoTargetGroup"
  }
}

# Creación del Listener para el ALB en el puerto 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}


# --- IAM Role para la ejecución de tareas de ECS ---

# Rol de IAM que ECS asume para ejecutar las tareas
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role_usac_demo"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Adjunta la política gestionada por AWS necesaria para la ejecución de tareas
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# --- Recursos de ECS ---

# Definición de la tarea de ECS
resource "aws_ecs_task_definition" "main" {
  family                   = "usac-demo-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # 0.25 vCPU
  memory                   = "512"  # 512 MB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "flask-color-app-container",
      image     = var.docker_image,
      essential = true,
      portMappings = [
        {
          containerPort = 5000,
          hostPort      = 5000
        }
      ],
      environment = [
        {
          name  = "APP_COLOR",
          value = var.app_color
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/usac-demo-task",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# Creación del grupo de logs en CloudWatch
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/usac-demo-task"

  tags = {
    Name = "UsacDemoECSLogs"
  }
}

# Creación del servicio de ECS
resource "aws_ecs_service" "main" {
  name            = "usac-demo-service"
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "flask-color-app-container"
    container_port   = 5000
  }

  # Asegurarse de que el listener del ALB esté creado antes de que el servicio intente registrarse
  depends_on = [aws_lb_listener.http]
}

