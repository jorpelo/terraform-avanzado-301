# M10-02 — Apply con aprobación

[← Página anterior](M10-01-validacion-plan-pr.md) · [Siguiente página →](M10-03-infracost-pr.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Crear un workflow que, al mergear a `main`, ejecute `terraform apply`, pero solo tras una
**aprobación manual** mediante un environment protegido.

### Prerrequisitos

- El workflow de validación (M10-01) y los secretos AWS configurados.

### En qué consiste

Creas un environment con revisor obligatorio y un workflow de `apply` que depende de él.

### 1 — Crea un environment protegido

**Acción:** En GitHub → **Settings → Environments → New environment**, crea `production` y activa
**Required reviewers** (añádete a ti).
**Por qué:** Es la puerta de aprobación: nada se aplica sin que alguien diga "sí".
**Resultado esperado:** Existe el environment `production` con revisor obligatorio.

### 2 — Crea el workflow de apply

**Acción:** Crea `.github/workflows/terraform-apply.yml`:

```yaml
name: terraform-apply
on:
  push:
    branches: ["main"]
    paths: ["environments/**", "modules/**"]

jobs:
  apply:
    runs-on: ubuntu-latest
    environment: production
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
      - run: terraform init
      - run: terraform apply -auto-approve
```

**Por qué:** `environment: production` hace que el job espere la aprobación antes de correr.
**Resultado esperado:** El workflow se dispara al mergear, pero queda **en espera**.

### 3 — Mergea y observa la espera

**Acción:** Mergea el PR de M10-01 a `main`.
**Por qué:** Compruebas que el `apply` no corre solo.
**Resultado esperado:** En **Actions** el job aparece como *Waiting* / *Review required*.

### 4 — Aprueba y verifica

**Acción:** En la ejecución, pulsa **Review deployments → Approve and deploy**.
**Por qué:** Es la decisión humana que autoriza el cambio.
**Resultado esperado:** El `apply` corre y crea/actualiza la infraestructura.

> [!WARNING]
> Esto aplica recursos reales. Hazlo en la ventana de clase y destruye lo creado al terminar
> (`terraform destroy` en local o un workflow de `destroy`).

## Comprueba tu entendimiento

**La puerta funciona**
Mergea a `main`.
→ El job de `apply` queda en espera de aprobación.

**Aprobación aplica**
Aprueba el deployment.
→ El `apply` se ejecuta y termina en verde.

## Reto

### 1 — `plan` guardado para el `apply`

¿Cómo te asegurarías de aplicar **exactamente** el plan que se revisó, y no uno recalculado?

<details>
<summary>Ver solución</summary>

Guarda el plan como artefacto en el job de PR (`terraform plan -out=tfplan`), súbelo con
`actions/upload-artifact`, y en el job de `apply` descárgalo y ejecuta `terraform apply tfplan`. Así
aplicas el plan aprobado, sin sorpresas por cambios entre medias.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| El `apply` corre sin esperar | El job no usa `environment:` protegido | Añade `environment: production` con required reviewers |
| `Error acquiring the state lock` | Otro run tiene el estado | Espera o libera el lock en TFC |
| El workflow no se dispara al merge | `branches`/`paths` no casan | Revisa el filtro `push` |
| Recursos quedan tras la práctica | Falta destruir | `terraform destroy` o workflow de limpieza |
