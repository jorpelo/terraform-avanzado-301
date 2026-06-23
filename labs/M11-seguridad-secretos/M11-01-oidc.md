# M11-01 — OIDC GitHub ↔ AWS

[← Página anterior](README.md) · [Siguiente página →](M11-02-minimo-privilegio.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Conectar GitHub Actions con AWS vía **OIDC** usando el proveedor y el rol **pre-creados** del curso,
y migrar el workflow de M10 para operar **sin claves estáticas**.

### Prerrequisitos

- El pipeline de M10 funcionando.
- Tu identificador de alumno (`AWS_LAB_USER`, p. ej. `david.pestana`).

### En qué consiste

Verificas el OIDC ya existente en la cuenta, localizas tu rol `lab-ci-<usuario>`, ajustas la trust
policy si hace falta y cambias el workflow para asumir ese rol.

> [!IMPORTANT]
> En este curso **no creas** el proveedor OIDC de GitHub: ya está en la cuenta compartida. Tu rol
> CI es `lab-ci-<AWS_LAB_USER>` (p. ej. `lab-ci-david.pestana`).

### 1 — Localiza tu rol CI

**Acción:**

```bash
source scripts/load-env.sh
aws --profile lab iam get-role --role-name lab-ci-${AWS_LAB_USER}
```

**Por qué:** Confirmas que existe el rol asignado a tu usuario y revisas su trust policy.
**Resultado esperado:** El rol existe; en `AssumeRolePolicyDocument` aparece el proveedor OIDC de
GitHub y una condición sobre tu repositorio.

### 2 — Revisa la trust policy (solo lectura + ajuste acotado)

**Acción:** Inspecciona el `sub` permitido. Debe parecerse a:

```
repo:TU-USUARIO/terraform-avanzado-301:ref:refs/heads/main
```

Si tu fork vive bajo tu usuario de GitHub, la condición debe apuntar a **tu fork**, no al repo
original del formador. Si el `sub` no coincide, pide al formador que lo ajuste o amplíe el patrón
(p. ej. `repo:TU-USUARIO/*`).

**Por qué:** OIDC falla en silencio si el token de GitHub no encaja con la trust policy.
**Resultado esperado:** Entiendes qué repo/rama/environment puede asumir el rol.

### 3 — Cambia el workflow para asumir el rol

**Acción:** En el workflow de apply (M10-02), sustituye las claves por OIDC:

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  apply:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::800789335147:role/lab-ci-TU-USUARIO
          aws-region: us-east-2
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
      - run: terraform apply -auto-approve
```

Sustituye `TU-USUARIO` por tu `AWS_LAB_USER`.

**Por qué:** El job obtiene credenciales temporales asumiendo el rol; ya no hay claves en Secrets.
**Resultado esperado:** El workflow ya no usa `AWS_ACCESS_KEY_ID`.

### 4 — Verifica que el pipeline funciona sin claves

**Acción:** Elimina los secretos `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` del repo (conserva
`AWS_REGION=us-east-2` si otros jobs lo necesitan) y dispara el workflow.
**Por qué:** Confirmas que ya no dependes de claves estáticas.
**Resultado esperado:** El `apply` corre asumiendo `lab-ci-<usuario>`; en los logs ves `Assuming role`.

> [!WARNING]
> Operaciones IAM reales. Hazlo en la ventana de clase.

## Comprueba tu entendimiento

**Sin claves estáticas**
Revisa los Secrets del repo.
→ Ya no hay `AWS_ACCESS_KEY_ID`; el pipeline sigue funcionando.

**Confianza acotada**
Mira la trust policy del rol `lab-ci-<usuario>`.
→ Solo confía en tu repo (y rama/environment definidos).

## Reto

### 1 — Restringir por entorno

¿Cómo permitirías asumir el rol solo desde el environment `production` y no desde cualquier rama?

<details>
<summary>Ver solución</summary>

En la condición del `sub` usa `repo:TU-USUARIO/terraform-avanzado-301:environment:production` en
lugar de `ref:refs/heads/main`. Así el token solo es válido cuando el job corre en ese environment
protegido.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `Not authorized to perform sts:AssumeRoleWithWebIdentity` | Trust policy no casa con tu `sub` | Revisa org/repo/ref exactos del fork |
| `Credentials could not be loaded` | Falta `permissions: id-token: write` | Añádelo al workflow |
| Rol no encontrado | Nombre distinto de `lab-ci-<AWS_LAB_USER>` | Confirma `AWS_LAB_USER` con el formador |
| Recursos denegados tras OIDC | Región distinta de `us-east-2` | `aws-region: us-east-2` en el workflow |
| Acceso AWS falla | Fuera de la ventana | Reintenta en sesión |
