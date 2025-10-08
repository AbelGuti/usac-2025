# USAC 2025 - Flask App en AWS ECS

[![Deploy to AWS ECS](https://github.com/AbelGuti/usac-2025/actions/workflows/deploy.yml/badge.svg)](https://github.com/AbelGuti/usac-2025/actions/workflows/deploy.yml)
[![Terraform](https://img.shields.io/badge/terraform-1.5.0-623CE4.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-ECS-FF9900.svg)](https://aws.amazon.com/ecs/)
[![Docker](https://img.shields.io/badge/docker-linux%2Famd64-2496ED.svg)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/python-3.9-3776AB.svg)](https://www.python.org/)

Aplicación Flask containerizada desplegada en AWS ECS con Terraform y CI/CD mediante GitHub Actions.

## Descripción

Este proyecto demuestra una arquitectura de microservicios en AWS utilizando:

- **Application**: Flask app containerizada con Docker
- **Infrastructure**: Terraform para IaC (Infrastructure as Code)
- **Container Registry**: Amazon ECR
- **Orchestration**: Amazon ECS con Fargate
- **Load Balancing**: Application Load Balancer (ALB)
- **CI/CD**: GitHub Actions para despliegue automatizado

## Arquitectura

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

## Quick Start

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

## CI/CD con GitHub Actions

El proyecto incluye **dos workflows principales** para asegurar calidad y automatizar despliegues:

### 1. Pull Request Validation (`.github/workflows/pr-validation.yml`)

Workflow profesional que se ejecuta en **cada PR** con validaciones automáticas:

#### Jobs de Validación:
- **terraform-validate**: Valida formato, sintaxis y configuración de Terraform
- **terraform-docs**: Genera y actualiza documentación automáticamente
- **test-flask-app**: Ejecuta tests unitarios con pytest y genera reportes de cobertura
- **pr-validation-summary**: Consolida resultados y determina si el PR puede mergearse

#### Características:
- Bloquea merge si las validaciones fallan
- Comenta resultados automáticamente en el PR
- Genera reportes de cobertura de tests
- Mantiene documentación de Terraform actualizada
- Integración con Branch Protection Rules

Ver [PR_VALIDATION.md](PR_VALIDATION.md) para detalles completos.

### 2. Deploy to AWS ECS (`.github/workflows/deploy.yml`)

Pipeline de despliegue que se ejecuta **solo en push a main** (después de merge):

#### Jobs de Deploy:
1. **build-and-push**: Construye y sube imagen Docker a ECR
2. **deploy-infrastructure**: Actualiza infraestructura con Terraform
3. **deploy-application**: Despliega y verifica estabilidad del servicio

### Configuración

Ver [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) para configurar secretos y permisos.

**Secretos requeridos:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Triggers

**PR Validation Workflow**:
- Pull Request a `main`: Validaciones automáticas
- Bloquea merge si falla alguna validación

**Deploy Workflow**:
- Push a `main`: Despliegue completo
- Manual: Desde la pestaña Actions

### Flujo Completo

```
Developer crea PR
        ↓
PR Validation ejecuta:
  - Terraform validation ✓
  - Generate docs ✓
  - Run tests ✓
        ↓
PR es revisado y aprobado
        ↓
Merge a main
        ↓
Deploy workflow ejecuta:
  - Build image ✓
  - Deploy infra ✓
  - Deploy app ✓
        ↓
Aplicación actualizada en producción
```