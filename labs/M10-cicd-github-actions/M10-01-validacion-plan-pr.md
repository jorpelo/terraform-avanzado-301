# M10-01 — Validación y plan en el PR

[← Página anterior](README.md) · [Siguiente página →](M10-02-apply-aprobacion.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Crear un workflow de GitHub Actions que, en cada Pull Request, ejecute `fmt -check`, `validate` y
`plan`.

### Prerrequisitos

- Tu fork (M01) y un entorno Terraform (p. ej. `environments/dev`).
- Credenciales AWS guardadas como **GitHub Secrets** (para `plan`).

### En qué consiste

Defines el workflow de validación, configuras los secretos y lo disparas con un PR.

### 1 — Crea el workflow de validación

**Acción:** Crea `.github/workflows/terraform-plan.yml`:

```yaml
name: terraform-plan
on:
  pull_request:
    paths: ["environments/**", "modules/**"]

jobs:
  plan:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: environments/dev
    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_REGION: us-east-2
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform fmt -check -recursive
      - run: terraform init
      - run: terraform validate
      - run: terraform plan -no-color
```

**Por qué:** Cada PR queda validado automáticamente antes de poder mezclarse.
**Resultado esperado:** El workflow existe y se dispara en PRs que tocan `environments/` o `modules/`.

### 2 — Configura los secretos

**Acción:** En GitHub → tu repo → **Settings → Secrets and variables → Actions**, añade
`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` y `AWS_REGION=us-east-2`.
**Por qué:** El `plan` necesita credenciales, pero no deben estar en el código.
**Resultado esperado:** Los secretos existen a nivel de repositorio.

> [!NOTE]
> Estas credenciales estáticas son temporales: en **M11** las sustituirás por OIDC (sin claves).

### 3 — Dispara el workflow con un PR

**Acción:** Crea una rama, haz un cambio pequeño en `environments/dev`, abre un PR.
**Por qué:** Compruebas que la validación corre sola.
**Resultado esperado:** En la pestaña **Checks** del PR ves `fmt`, `validate` y `plan` en verde.

### 4 — Comprueba que un fallo bloquea

**Acción:** Mete a propósito un error de formato (una indentación rara) y vuelve a empujar.
**Por qué:** Verificas que `fmt -check` falla y marca el PR.
**Resultado esperado:** El check de `fmt` pasa a rojo; arréglalo con `terraform fmt` y vuelve a verde.

## Comprueba tu entendimiento

**El workflow corre en el PR**
Abre la pestaña **Checks** del PR.
→ Aparecen los pasos `validate` y `plan`.

**El formato se exige**
Rompe el formato y empuja.
→ El check `fmt -check` falla.

## Reto

### 1 — Publicar el plan como comentario

¿Cómo harías que el resultado del `plan` aparezca como comentario en el PR para que el revisor no
tenga que abrir los logs?

<details>
<summary>Ver solución</summary>

Captura la salida de `plan` y publícala con la API de GitHub (p. ej. una acción como
`actions/github-script` o pasos que usen `gh pr comment`). Así el revisor ve el diff de
infraestructura directamente en la conversación del PR.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| El workflow no se dispara | El `paths` no casa con tus cambios | Ajusta `paths` o quítalo para probar |
| `No valid credential sources` | Faltan secretos AWS | Añádelos en Settings → Secrets |
| `fmt -check` siempre falla | Código sin formatear | Corre `terraform fmt -recursive` y commitea |
| `working-directory` no encuentra archivos | Ruta del entorno equivocada | Ajusta `defaults.run.working-directory` |
