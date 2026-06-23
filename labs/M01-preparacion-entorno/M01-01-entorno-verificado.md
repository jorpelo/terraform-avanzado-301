# M01-01 — Entorno verificado

[← Página anterior](README.md) · [Siguiente página →](../M02-organizacion-proyectos/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Dejar el dev container abierto, con credenciales activas, **rol de laboratorio asumido** y el
**tester de permisos en verde**.

### Prerrequisitos

- Cuenta de GitHub y acceso al repositorio base del curso.
- Credenciales de AWS del curso (las facilita el formador), dentro de la ventana de acceso.

### En qué consiste

Forkeas, abres el entorno, cargas credenciales + rol, verificas identidad y herramientas, y lanzas
el tester de permisos del curso.

### 1 — Haz un fork del repositorio base

**Acción:** En el repositorio base, pulsa **Fork** y confirma con **Create fork**.
**Por qué:** Necesitas tu propia copia para trabajar sin afectar al original.
**Resultado esperado:** La URL es `github.com/tu-usuario/terraform-avanzado-301`.

### 2 — Abre el dev container

**Acción:**
- En **Codespaces**: **Code → Codespaces → Create codespace on main**.
- En **local**: clona tu fork, ábrelo en VS Code y elige **Reopen in Container** (requiere Docker).

**Por qué:** Es tu entorno del curso, con todo el tooling ya instalado.
**Resultado esperado:** Se abre VS Code con una terminal; al final ves la salida de bienvenida del setup.

### 3 — Inyecta tus credenciales (elige una vía)

**Acción:** Según dónde trabajes:

- **Codespaces (recomendado):** en GitHub → Settings → Codespaces → Secrets, crea:
  - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION` y `AWS_DEFAULT_REGION` = `us-east-2`
  - `AWS_ROLE_ARN` = `arn:aws:iam::800789335147:role/lab-role-curso`
  - `AWS_LAB_USER` = tu identificador (p. ej. `david.pestana`)
  - `AWS_ROLE_SESSION_NAME` = `tf-curso` (opcional)
  - Luego **Rebuild Container**.

- **Codespaces con `.env`:** el `.env` no viaja con git. Créalo en el Codespace:
  ```bash
  cp .env.example .env   # edita con tus claves
  source scripts/load-env.sh
  ```

- **Local:** `cp .env.example .env`, edita y `direnv allow` (o `source scripts/load-env.sh`).

**Por qué:** Las keys de usuario son solo la puerta de entrada; los permisos reales vienen del rol
`lab-role-curso`. El prefijo `AWS_LAB_USER` fija la convención de nombres (`curso-<usuario>-*`).
**Resultado esperado:** Las variables están en el entorno y el perfil `lab` queda en `~/.aws/config`.

> [!TIP]
> En Codespaces, los *secrets* solo se cargan al **(re)crear** el Codespace. Si los añadiste
> después, reábrelo (Command Palette → *Rebuild Container*).

### 4 — Verifica identidad y herramientas

**Acción:**

```bash
source scripts/load-env.sh          # si no usaste direnv/secrets completos
aws --profile lab sts get-caller-identity
terraform version
ansible --version
tflint --version
```

**Por qué:** Confirmas que operas con el **rol asumido** (no solo con el usuario IAM base).
**Resultado esperado:** El `Arn` incluye `assumed-role/lab-role-curso/...`; el resto imprime versiones.

> [!IMPORTANT]
> Usa **`aws --profile lab`**. Con las keys en el entorno, `AWS_PROFILE=lab` solo no basta para
> asumir el rol. Los scripts del curso (`check-aws-permissions.sh`) lo hacen automáticamente.

### 5 — Comprueba los permisos con el tester del curso

**Acción:**

```bash
./scripts/check-aws-permissions.sh
```

**Por qué:** Confirmas permisos en **us-east-2** con prefijos `curso-<usuario>-*` (S3, IAM, EC2).
**Resultado esperado:** Un resumen con `FAIL=0`. Si hay algún `FAIL`, compártelo con el formador.

### 6 — Inicia sesión en Terraform Cloud

**Acción:** `terraform login` y pega el token cuando se te pida.
**Por qué:** A partir de M08 guardarás el estado en Terraform Cloud; deja el acceso listo ya.
**Resultado esperado:** `Success! Terraform has obtained and saved an API token`.

## Comprueba tu entendimiento

**Identidad con rol asumido**
Ejecuta `aws --profile lab sts get-caller-identity`.
→ El `Arn` contiene `assumed-role/lab-role-curso`.

**Permisos suficientes**
Ejecuta `./scripts/check-aws-permissions.sh`.
→ El resumen final muestra `FAIL=0`.

**Tooling disponible**
Ejecuta `terraform version` y `ansible --version`.
→ Ambos imprimen su versión sin errores.

## Reto

### 1 — ¿Qué vía de credenciales usarías en un pipeline?

Para tu portátil vale un `.env`; para Codespaces, los *secrets*. Pero, ¿qué usarías en un pipeline
de CI/CD para no dejar claves estáticas en ningún sitio?

<details>
<summary>Ver solución</summary>

**OIDC**: el pipeline asume un rol de AWS con un token efímero, sin almacenar claves. Lo montarás en
**M11** con el rol pre-creado `lab-ci-<usuario>`. Las claves estáticas son la última opción.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `NoCredentials` | No cargaste `.env` ni secrets | `source scripts/load-env.sh` o rebuild Codespace |
| `get-caller-identity` OK pero sin `assumed-role` | No usaste `--profile lab` | `aws --profile lab sts get-caller-identity` |
| Fuera de ventana AWS | Horario de clase | Reintenta en sesión |
| `No region` | Falta `AWS_REGION` | `us-east-2` en secrets o `.env` |
| Buckets denegados | Nombre sin prefijo `curso-<usuario>-` | Revisa `AWS_LAB_USER` y la convención del curso |
| Secrets no cargan | Añadidos con Codespace abierto | *Rebuild Container* |
| Tester `FAIL` en S3 | Prefijo incorrecto o región distinta | Región `us-east-2`; buckets `curso-<usuario>-*` |
