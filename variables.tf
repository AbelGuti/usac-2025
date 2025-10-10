variable "aws_region" {
  description = "La región de AWS donde se desplegarán los recursos."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "El ID de la VPC existente donde se desplegarán los recursos."
  type        = string
  default     = "vpc-0d0a9db77fd5f54fe"
}

variable "ecs_cluster_name" {
  description = "El nombre del clúster de ECS existente."
  type        = string
  default     = "USAC-2025"
}

variable "docker_image" {
  description = "La URL completa de la imagen de Docker a desplegar (ej. en ECR)."
  type        = string
  default     = "737584674007.dkr.ecr.us-east-1.amazonaws.com/usac-2025:latest"
}

variable "app_color" {
  description = "El color de fondo para la aplicación Flask."
  type        = string
  default     = "Blue"
}

variable "public_subnets" {
  description = "Una lista de IDs de subredes públicas para el ALB."
  type        = list(string)
  default = [
    "subnet-054f367abf11f8e44",
    "subnet-0e6ea13d854b28065",
    "subnet-0fcbfb26cae694be3"
  ]
}

variable "private_subnets" {
  description = "Una lista de IDs de subredes privadas para las tareas de ECS."
  type        = list(string)
  default = [
    "subnet-003986e9f0c9b89a1",
    "subnet-077449c6fb4d68931",
    "subnet-06f4ce867851aeb67"
  ]
}

