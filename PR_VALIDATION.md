# Pull Request Validation Workflow

## Descripción

Este workflow implementa un sistema de validación profesional para Pull Requests que asegura la calidad del código antes de permitir el merge a la rama `main`.

## Flujo de Validación

Cuando se crea o actualiza un Pull Request contra `main`, se ejecutan automáticamente 4 jobs:

```
┌────────────────────────────────────────────────────────────┐
│                    PR Validation Workflow                   │
└────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐      ┌──────────────┐
│  Terraform   │    │  Terraform   │      │  Flask Unit  │
│  Validation  │    │  Docs        │      │  Tests       │
└──────┬───────┘    └──────┬───────┘      └──────┬───────┘
       │                   │                      │
       └───────────────────┼──────────────────────┘
                           ▼
                  ┌──────────────┐
                  │ PR Summary   │
                  │  & Status    │
                  └──────────────┘
```

## Jobs del Workflow

### 1. Terraform Validation

**Propósito**: Validar la configuración de Terraform

**Pasos**:
- ✅ `terraform fmt -check`: Verifica formato del código
- ✅ `terraform init`: Inicializa el backend
- ✅ `terraform validate`: Valida la sintaxis y configuración
- ✅ `terraform plan`: Genera plan de cambios
- 📝 Comenta resultados en el PR

**Criterios de Falla**:
- Código no está formateado correctamente
- Errores de sintaxis en archivos `.tf`
- Validación de Terraform falla

### 2. Terraform Documentation

**Propósito**: Mantener documentación actualizada automáticamente

**Pasos**:
- 📚 Genera documentación usando `terraform-docs`
- 📝 Actualiza archivo `TERRAFORM.md`
- 🔄 Hace commit del archivo actualizado al PR

**Características**:
- Documenta inputs, outputs, resources y providers
- Se ejecuta solo si la validación de Terraform es exitosa
- Commit automático con mensaje: `"docs: update Terraform documentation"`

### 3. Flask Unit Tests

**Propósito**: Ejecutar pruebas unitarias de la aplicación Flask

**Pasos**:
- 🐍 Setup Python 3.9
- 📦 Instala dependencias (`pip install -r requirements.txt`)
- 🧪 Ejecuta tests con `pytest`
- 📊 Genera reporte de cobertura
- 📈 Publica resultados en el PR

**Tests Incluidos**:
- ✅ Status code de rutas
- ✅ Contenido HTML
- ✅ Variables de entorno
- ✅ Manejo de rutas inválidas
- ✅ Tests de integración

**Salida**:
- Reporte de tests en comentario del PR
- Artifact con reporte de cobertura XML
- Resultados detallados en checks del PR

### 4. PR Validation Summary

**Propósito**: Consolidar resultados y determinar si el PR puede mergearse

**Pasos**:
- 📊 Revisa status de todos los jobs anteriores
- ✅/❌ Determina si el PR pasa todas las validaciones
- 📝 Comenta resumen final en el PR con tabla de resultados

**Criterios de Aprobación**:
- ✅ Terraform validation debe ser exitosa
- ✅ Flask tests deben pasar
- ℹ️ Terraform docs es informativo (no bloquea merge)

## Configuración de Branch Protection

Para que este workflow sea efectivo, configura las siguientes reglas de protección en GitHub:

### Paso 1: Ir a Settings → Branches → Branch protection rules

### Paso 2: Agregar regla para `main`

Configura las siguientes opciones:

#### Require a pull request before merging
- ✅ Activar
- Require approvals: 1 (recomendado)
- ✅ Dismiss stale pull request approvals when new commits are pushed

#### Require status checks to pass before merging
- ✅ Activar
- ✅ Require branches to be up to date before merging

**Status checks requeridos**:
- `Terraform Validation`
- `Test Flask Application`
- `PR Validation Summary`

#### Require conversation resolution before merging
- ✅ Activar (recomendado)

#### Do not allow bypassing the above settings
- ✅ Activar

### Configuración en YAML

Alternativamente, puedes usar la API de GitHub o archivo `.github/settings.yml`:

```yaml
branches:
  - name: main
    protection:
      required_pull_request_reviews:
        required_approving_review_count: 1
        dismiss_stale_reviews: true
      required_status_checks:
        strict: true
        contexts:
          - "Terraform Validation"
          - "Test Flask Application"
          - "PR Validation Summary"
      enforce_admins: true
      restrictions: null
```

## Comentarios Automáticos en PRs

El workflow genera tres tipos de comentarios:

### 1. Terraform Validation Results
```
#### Terraform Format and Style 🖌`success`
#### Terraform Validation 🤖`success`
#### Terraform Plan 📖`success`

<details><summary>Show Plan</summary>
...plan output...
</details>
```

### 2. Flask Test Results
```
### ✅ Flask Unit Tests - `success`

Los tests unitarios de la aplicación Flask han sido ejecutados.

- Python Version: 3.9
- Test Framework: pytest
- Coverage Report: Disponible en artifacts
```

### 3. Final Summary
```
## 🎉 PR Validation Summary

| Check | Status |
|-------|--------|
| Terraform Validation | ✅ success |
| Terraform Documentation | ✅ success |
| Flask Unit Tests | ✅ success |

### ✅ All checks passed! This PR is ready to merge.
```

## Permisos Requeridos

El workflow necesita los siguientes permisos:

```yaml
permissions:
  contents: write      # Para commitear TERRAFORM.md
  pull-requests: write # Para comentar en PRs
  statuses: write      # Para reportar status checks
```

## Archivos de Configuración

### `.terraform-docs.yml`
Configura cómo se genera la documentación de Terraform:
- Formato: Markdown table
- Output: `TERRAFORM.md`
- Incluye: Requirements, Providers, Resources, Inputs, Outputs

### `app/test_app.py`
Contiene las pruebas unitarias de Flask:
- 8+ test cases
- Cobertura de rutas principales
- Tests de variables de entorno
- Tests de integración

## Troubleshooting

### El workflow no se ejecuta
- Verifica que el evento sea `pull_request`
- Asegúrate de que el target sea la rama `main`
- Revisa que el archivo esté en `.github/workflows/`

### Terraform-docs no commitea cambios
- Verifica que el token tenga permisos de `contents: write`
- Asegúrate de que exista el archivo `TERRAFORM.md`
- Revisa que `.terraform-docs.yml` esté configurado correctamente

### Tests de Flask fallan
- Verifica que `test_app.py` esté en el directorio `app/`
- Asegúrate de que `requirements.txt` esté actualizado
- Revisa los logs del job para ver errores específicos

### Status checks no aparecen
- Verifica que los nombres en branch protection coincidan exactamente
- Asegúrate de que el workflow se haya ejecutado al menos una vez
- Los status checks aparecen después de la primera ejecución

## Mejores Prácticas

1. **Commits Frecuentes**: Haz commits pequeños y frecuentes para validaciones más rápidas
2. **Descripción Clara**: Escribe descripciones claras en tus PRs
3. **Tests Locales**: Ejecuta tests localmente antes de push
4. **Terraform Format**: Ejecuta `terraform fmt` antes de commit
5. **Review Logs**: Revisa los logs si algo falla para entender el problema

## Comandos Útiles Locales

### Ejecutar tests de Flask localmente
```bash
cd app
pip install -r requirements.txt
pip install pytest pytest-cov
python -m pytest test_app.py -v --cov=app
```

### Validar Terraform localmente
```bash
terraform fmt -check
terraform init
terraform validate
terraform plan
```

### Generar documentación de Terraform localmente
```bash
terraform-docs markdown table . > TERRAFORM.md
```

## Integración con Otros Workflows

Este workflow se ejecuta **independientemente** del workflow de deploy:

- **PR Validation**: Se ejecuta en PRs, valida y bloquea merge si falla
- **Deploy**: Se ejecuta solo en push a `main` (después del merge)

Esto asegura que:
1. Todo código pase validaciones antes de llegar a `main`
2. Solo código validado se despliegue a producción
3. Los deployments sean más confiables

## Métricas y Reportes

### Artifacts Generados
- `coverage-report`: Reporte XML de cobertura de tests
- `test-results.xml`: Resultados de tests en formato JUnit

### Acceder a Artifacts
1. Ve al workflow run en GitHub Actions
2. Scroll hasta la sección "Artifacts"
3. Descarga los reportes

### Ver Coverage Report
```bash
# Descargar artifact y abrir
pip install coverage
coverage report --show-missing
```

## Recursos Adicionales

- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [Terraform-docs](https://terraform-docs.io/)
- [Pytest Documentation](https://docs.pytest.org/)
- [GitHub Actions - Status Checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/about-status-checks)
