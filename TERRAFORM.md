# Terraform Infrastructure Documentation

<!-- BEGIN_TF_DOCS -->


## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.ecs_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.alb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ecs_service_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_color"></a> [app\_color](#input\_app\_color) | El color de fondo para la aplicación Flask. | `string` | `"Blue"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | La región de AWS donde se desplegarán los recursos. | `string` | `"us-east-1"` | no |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | La URL completa de la imagen de Docker a desplegar (ej. en ECR). | `string` | `"737584674007.dkr.ecr.us-east-1.amazonaws.com/usac-2025:latest"` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | El nombre del clúster de ECS existente. | `string` | `"USAC-2025"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | Una lista de IDs de subredes privadas para las tareas de ECS. | `list(string)` | <pre>[<br>  "subnet-003986e9f0c9b89a1",<br>  "subnet-077449c6fb4d68931",<br>  "subnet-06f4ce867851aeb67"<br>]</pre> | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Una lista de IDs de subredes públicas para el ALB. | `list(string)` | <pre>[<br>  "subnet-054f367abf11f8e44",<br>  "subnet-0e6ea13d854b28065",<br>  "subnet-0fcbfb26cae694be3"<br>]</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | El ID de la VPC existente donde se desplegarán los recursos. | `string` | `"vpc-0d0a9db77fd5f54fe"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | El nombre DNS del Application Load Balancer. |
<!-- END_TF_DOCS -->
