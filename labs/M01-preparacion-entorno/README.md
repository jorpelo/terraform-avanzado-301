# M01 — Preparación del entorno

[← Página anterior](../../README.md) · [Siguiente página →](M01-01-entorno-verificado.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría** (qué piezas usarás y por qué), luego la
> **demostración guiada** que hace el formador, y después **practicas tú** en el laboratorio.

## Qué aprenderás

- Para qué sirve cada pieza: **fork**, **dev container** (Codespaces o local), **Terraform Cloud**.
- Las **distintas vías** de inyectar credenciales de AWS (Codespaces secrets, `.env` local, asunción de rol).
- Cómo **verificar** identidad, herramientas y, sobre todo, que tienes los **permisos** necesarios.

## Teoría

El curso separa dos cosas a propósito:

- **El tooling viene resuelto.** El dev container (definido en `.devcontainer/`) construye una
  imagen con Terraform, AWS CLI v2, Ansible y tflint. No instalas nada a mano.
- **Las credenciales las pones tú**, y hay varias formas. Saber elegir es parte del oficio:

| Vía | Cuándo | Cómo |
|-----|--------|------|
| **Codespaces secrets** | Trabajas en Codespaces | Settings → Codespaces → Secrets (`AWS_*`, `AWS_ROLE_ARN`, `AWS_LAB_USER`). Rebuild al añadir. |
| **`.env` + `load-env.sh`** | Codespaces o local | `cp .env.example .env`, edítalo y `source scripts/load-env.sh`. |
| **`.env` + direnv** | Local con Docker | `cp .env.example .env`, edítalo y `direnv allow`. |
| **Asunción de rol** | Siempre en este curso | Keys del usuario + `AWS_ROLE_ARN=.../lab-role-curso`; operas con `aws --profile lab`. |

| Pieza | Para qué sirve |
|-------|----------------|
| **Fork** | Tu copia del repositorio base, que harás crecer durante el curso. |
| **Dev container** | Tu entorno reproducible (en la nube con Codespaces o en local con Docker). |
| **Terraform Cloud** | Estado remoto y colaboración (lo usarás a partir de M08). |

> [!NOTE]
> **Nunca** escribas tus claves dentro del código ni en archivos versionados. El `.env` está en
> `.gitignore`; en Codespaces las claves viven en *secrets*, fuera del repositorio.

> [!IMPORTANT]
> La cuenta AWS del curso solo está disponible **alrededor del horario de clase**. Fuera de esa
> ventana, el acceso falla: es lo esperado.

## Demostración guiada

> Recorrido que hace el formador en vivo. El alumno lo repite después en el laboratorio.

1. **Fork del repositorio base.** Desde la página del repo base, el botón **Fork** crea una copia
   en la cuenta del alumno; la URL pasa a ser `github.com/<usuario>/terraform-avanzado-301`.
2. **Apertura del dev container.** En **Codespaces** (*Code → Create codespace*) o en local
   (*Reopen in Container*). Al terminar la construcción, el `postCreateCommand` ejecuta
   `setup-aws-profiles.sh`, que imprime un "panel de bienvenida": herramientas detectadas, si hay
   credenciales activas y, si no, las vías para ponerlas.
3. **Credenciales y rol.** Se cargan keys + `AWS_ROLE_ARN` (rol `lab-role-curso`) y región
   `us-east-2`. Tras `source scripts/load-env.sh`, `aws --profile lab sts get-caller-identity`
   debe mostrar el rol asumido.
4. **Verificación de permisos.** Se lanza `./scripts/check-aws-permissions.sh`, que comprueba —sin
   riesgo— que la cuenta puede hacer todo lo que pedirán los labs (S3, IAM/STS, EC2/VPC).

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M01-01 | [Entorno verificado](M01-01-entorno-verificado.md) | Abrir el dev container, inyectar credenciales y verificar identidad, tooling y permisos |

→ Empieza por **[M01-01 — Entorno verificado](M01-01-entorno-verificado.md)**.
