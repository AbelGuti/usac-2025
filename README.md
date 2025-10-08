# USAC 2025 - Flask App en AWS ECS

[![Deploy to AWS ECS](https://github.com/AbelGuti/usac-2025/actions/workflows/deploy.yml/badge.svg)](https://github.com/AbelGuti/usac-2025/actions/workflows/deploy.yml)
[![Terraform](https://img.shields.io/badge/terraform-1.5.0-623CE4.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-ECS-FF9900.svg)](https://aws.amazon.com/ecs/)
[![Docker](https://img.shields.io/badge/docker-linux%2Famd64-2496ED.svg)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/python-3.9-3776AB.svg)](https://www.python.org/)

Aplicación Flask containerizada desplegada en AWS ECS con Terraform y CI/CD mediante GitHub Actions.

## 📋 Descripción

Este proyecto demuestra una arquitectura de microservicios en AWS utilizando:

- **Application**: Flask app containerizada con Docker
- **Infrastructure**: Terraform para IaC (Infrastructure as Code)
- **Container Registry**: Amazon ECR
- **Orchestration**: Amazon ECS con Fargate
- **Load Balancing**: Application Load Balancer (ALB)
- **CI/CD**: GitHub Actions para despliegue automatizado

## 🏗️ Arquitectura

```
┌─────────────┐
│   GitHub    │
│   Actions   │ (CI/CD Pipeline)
└──────┬──────┘
       │
       ├──────────────┐
       │              │
       ▼              ▼
┌──────────┐   ┌─────────────┐
│   ECR    │   │  Terraform  │
│(Registry)│   │   (IaC)     │
└────┬─────┘   └──────┬──────┘
     │                │
     └────────┬───────┘
              │
              ▼
┌─────────────────────────┐
│    Application LB       │ :80
└────────────┬────────────┘
             │
    ┌────────┴────────┐
    │                 │
    ▼                 ▼
┌────────┐       ┌────────┐
│ECS Task│       │ECS Task│
│ Flask  │       │ Flask  │
│  :5000 │       │  :5000 │
└────────┘       └────────┘
```

## 🚀 Quick Start

### Prerrequisitos

- AWS CLI configurado
- Terraform >= 1.5.0
- Docker Desktop (para Mac M-series usar builds multi-plataforma)
- Git

### 1. Clonar el repositorio

```bash
git clone git@github.com:AbelGuti/usac-2025.git
cd usac-2025
```

### 2. Configurar variables de Terraform

Las variables están preconfiguradas en `variables.tf`. Revisa y ajusta si es necesario:

- `aws_region`: us-east-1 (default)
- `vpc_id`: VPC existente
- `ecs_cluster_name`: USAC-2025
- `docker_image`: URL de imagen en ECR
- `public_subnets`: Subnets para el ALB
- `private_subnets`: Subnets para las tareas ECS

### 3. Desplegar infraestructura

```bash
# Inicializar Terraform
terraform init

# Ver plan de ejecución
terraform plan

# Aplicar cambios
terraform apply
```

### 4. Build y Deploy manual (opcional)

Si deseas construir y desplegar manualmente sin GitHub Actions:

```bash
# Usar el script helper
./build-and-push.sh

# O manualmente
cd app
docker buildx build --platform linux/amd64 \
  -t 737584674007.dkr.ecr.us-east-1.amazonaws.com/usac-2025:latest .
docker push 737584674007.dkr.ecr.us-east-1.amazonaws.com/usac-2025:latest

# Forzar nuevo deployment
aws ecs update-service \
  --cluster USAC-2025 \
  --service usac-demo-service \
  --force-new-deployment \
  --region us-east-1
```

## 🔄 CI/CD con GitHub Actions

El proyecto incluye un pipeline CI/CD **modular** con tres jobs principales:

### En Pull Requests:
- **terraform-validate**: Valida formato y configuración de Terraform

### En Push a main:
1. **build-and-push**: Construye y sube imagen Docker a ECR
2. **deploy-infrastructure**: Actualiza infraestructura con Terraform
3. **deploy-application**: Despliega y verifica estabilidad del servicio

### Configuración

Ver [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) para configurar secretos y permisos.

**Secretos requeridos:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Triggers

- **Push a main**: Despliegue completo
- **Pull Request**: Solo validación de Terraform
- **Manual**: Desde la pestaña Actions

## 🐛 Solución de Problemas

### Error: Incompatibilidad de arquitectura (ARM vs AMD64)

Si construiste la imagen localmente en Mac M-series y obtienes el error:

```
CannotPullContainerError: image Manifest does not contain descriptor matching platform 'linux/amd64'
```

**Solución**: Construir con la plataforma correcta

```bash
docker buildx build --platform linux/amd64 -t <imagen>:tag .
```

**Nota**: El pipeline de GitHub Actions construye automáticamente en `linux/amd64` (arquitectura nativa de los runners), por lo que este problema solo ocurre en builds locales desde Mac M-series.

Ver [SOLUCION_BUILD_MULTIPLATFORM.md](SOLUCION_BUILD_MULTIPLATFORM.md) para más detalles.

### Ver logs de la aplicación

```bash
# Ver logs en tiempo real
aws logs tail /ecs/usac-demo-task --follow --region us-east-1

# Ver estado del servicio
aws ecs describe-services \
  --cluster USAC-2025 \
  --services usac-demo-service \
  --region us-east-1
```

### Obtener URL de la aplicación

```bash
aws elbv2 describe-load-balancers \
  --names usac-demo-alb \
  --region us-east-1 \
  --query 'LoadBalancers[0].DNSName' \
  --output text
```

## 📁 Estructura del Proyecto

```
usac-2025/
├── .github/
│   └── workflows/
│       └── deploy.yml              # Pipeline modular de GitHub Actions
├── app/
│   ├── app.py                      # Aplicación Flask
│   ├── Dockerfile                  # Configuración del container
│   └── requirements.txt            # Dependencias Python
├── main.tf                         # Recursos principales de Terraform
├── variables.tf                    # Variables de Terraform
├── outputs.tf                      # Outputs de Terraform
├── backend.tf                      # Configuración del backend de Terraform
├── build-and-push.sh              # Script helper para build manual
├── GITHUB_ACTIONS_SETUP.md        # Guía de configuración de CI/CD
├── SOLUCION_BUILD_MULTIPLATFORM.md # Guía de arquitectura Docker
└── README.md                       # Este archivo
```

## 🛠️ Tecnologías Utilizadas

- **Infrastructure as Code**: Terraform
- **Cloud Provider**: AWS (ECS, ECR, ALB, VPC)
- **Containerization**: Docker
- **Application**: Python 3.9 + Flask
- **CI/CD**: GitHub Actions
- **Monitoring**: AWS CloudWatch

## 📊 Recursos de AWS Creados

- Application Load Balancer (ALB)
- Target Group
- Security Groups (ALB y ECS)
- ECS Task Definition
- ECS Service (Fargate)
- CloudWatch Log Group
- IAM Role para ejecución de tareas

## 🔒 Seguridad

- Security Groups con reglas mínimas necesarias
- Tareas ECS en subnets privadas
- ALB en subnets públicas
- Logs centralizados en CloudWatch
- IAM Roles con permisos mínimos necesarios

## 📚 Documentación Adicional

- [Configuración de GitHub Actions](GITHUB_ACTIONS_SETUP.md)
- [Solución de problemas de arquitectura Docker](SOLUCION_BUILD_MULTIPLATFORM.md)

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama de feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

## 📝 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 👨‍💻 Autor

Abel Gutierrez - [@AbelGuti](https://github.com/AbelGuti)

## 🙏 Agradecimientos

- Universidad de San Carlos de Guatemala (USAC)
- AWS Documentation
- Terraform Documentation
- GitHub Actions Documentation
