# M04-02 — Módulo S3 parametrizable

[← Página anterior](M04-01-modulos-naming-tagging.md) · [Siguiente página →](../M05-versionado-modulos/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Encapsular un bucket S3 (con versionado opcional) en un módulo y componerlo con los de naming y
tagging. Diseño y `plan` son locales; el `apply` es opcional.

### Prerrequisitos

- Haber hecho M04-01 (módulos `naming` y `tags` ya consumidos en `environments/dev`).
- Tener definido tu identificador de alumno en el `.env` como `AWS_LAB_USER` (M01), p. ej.
  `david.pestana`. Lo reutilizarás en Terraform como `lab_user`.

### En qué consiste

Defines `modules/s3` con inputs/outputs y lo conectas a los módulos de naming/tagging del entorno.

### 1 — Crea el módulo S3

**Acción:** Crea `modules/s3/main.tf`:

```hcl
variable "bucket_name" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

variable "versioning" {
  type    = bool
  default = true
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

output "bucket_id"  { value = aws_s3_bucket.this.id }
output "bucket_arn" { value = aws_s3_bucket.this.arn }
```

**Por qué:** Encapsulas un bucket con versionado configurable, listo para reutilizar.
**Resultado esperado:** El módulo expone `bucket_id` y `bucket_arn`.

### 2 — Declara la variable `lab_user`

El nombre del bucket usa `var.lab_user`, pero esa variable **no viene de M02**: debes declararla
ahora. Debe coincidir con `AWS_LAB_USER` de tu `.env` (M01): es el prefijo que exige el rol del
laboratorio (`curso-<usuario>-*`).

**Acción:** En `environments/dev/variables.tf`, añade:

```hcl
variable "lab_user" {
  type        = string
  description = "Identificador del alumno (mismo valor que AWS_LAB_USER del .env)"
}
```

En `environments/dev/terraform.tfvars`, añade tu identificador:

```hcl
lab_user = "david.pestana"   # sustituye por tu AWS_LAB_USER
```

**Por qué:** Sin esta variable, `terraform validate`/`plan` fallan con
`Reference to undeclared input variable "lab_user"`. Con un valor distinto de `AWS_LAB_USER`, el
`apply` puede crear el bucket pero el rol no te dejará borrarlo o listarlo.
**Resultado esperado:** `terraform validate` pasa y el plan muestra un nombre tipo
`curso-david.pestana-data-us-east-2`.

### 3 — Compón con naming y tagging

**Acción:** En `environments/dev/main.tf`, añade:

```hcl
module "bucket" {
  source      = "../../modules/s3"
  bucket_name = "curso-${var.lab_user}-data-${var.aws_region}"
  tags        = module.tags.tags
}

output "bucket_id" { value = module.bucket.bucket_id }
```

**Por qué:** El nombre y las etiquetas vienen de los otros módulos: composición real.
**Resultado esperado:** El bucket usará un nombre coherente con la convención.

### 4 — Inicializa y planifica

**Acción:**

```bash
cd environments/dev
terraform init
terraform plan
```

**Por qué:** Compruebas qué se crearía sin aplicar todavía.
**Resultado esperado:** `plan` propone crear el bucket con nombre y etiquetas correctos.

### 5 — (Opcional) Aplica y destruye

**Acción:**

```bash
terraform apply -auto-approve -refresh=false
# Comprueba que el bucket existe (sustituye <usuario> por tu lab_user):
aws s3api head-bucket --bucket curso-<usuario>-data-us-east-2
terraform destroy -auto-approve -refresh=false
```

**Por qué:** Si quieres verlo real, créalo y elimínalo en la misma sesión. El flag `-refresh=false`
evita lecturas S3 que el rol del laboratorio no tiene (ver sección siguiente).
**Resultado esperado:** El bucket se crea y luego se destruye.

> [!WARNING]
> Este paso crea un recurso real en AWS. Hazlo dentro de la ventana de clase y **destruye al
> terminar**. Si solo practicas el diseño, quédate en `plan`.

### Permisos del rol del laboratorio

En el curso no trabajas con acceso administrador a AWS. Operas a través de una **capa de permisos
restringida**: asumes el rol `LabRole-curso` (perfil `lab`), diseñado con **mínimo privilegio** para
que solo puedas crear y borrar recursos propios del curso (prefijo `curso-<usuario>-*` en
**us-east-2**).

Eso implica una diferencia importante entre **lo que Terraform necesita leer** y **lo que el rol
puede leer**:

| Capa | Qué ocurre |
|------|------------|
| **Tu código** | Correcto: define bucket, versionado y tags. |
| **Rol del lab** | Permite crear, etiquetar, versionar y borrar buckets del curso. |
| **Provider AWS 5.x** | Antes de `apply`/`destroy`, intenta **refrescar** el estado leyendo muchas APIs del bucket (website, CORS, lifecycle…). |
| **Conflicto** | El rol **no** incluye lecturas como `s3:GetBucketWebsite` → **403 AccessDenied**, aunque el bucket exista. |

**No es un error tuyo.** El bucket se creó bien; falla la fase de *refresh* porque el provider pide
más permisos de lectura de los que la capa de seguridad del laboratorio concede.

El tester del curso (`./scripts/check-aws-permissions.sh`) valida las operaciones que sí necesitas
para los labs:

| Acción | ¿Disponible en el rol? |
|--------|------------------------|
| `s3:CreateBucket` | Sí |
| `s3:DeleteBucket` | Sí |
| `s3:PutBucketVersioning` / `s3:GetBucketVersioning` | Sí |
| `s3:PutObject` / `s3:ListBucket` | Sí |
| `s3:PutBucketTagging` / `s3:GetBucketTagging` | Sí |
| `s3:GetBucketWebsite` y otras lecturas al refrescar | **No** (por diseño del entorno) |

**Solución en este lab:** evita el refresh y confía en el estado local con `-refresh=false`:

```bash
terraform apply -auto-approve -refresh=false
terraform destroy -auto-approve -refresh=false
```

Así Terraform aplica o destruye usando el estado que ya tiene, sin llamar a APIs de lectura que el
rol no autoriza.

Si el `destroy` falla por el versionado, destruye en dos pasos:

```bash
terraform destroy -auto-approve -refresh=false -target=module.bucket.aws_s3_bucket_versioning.this
terraform destroy -auto-approve -refresh=false -target=module.bucket.aws_s3_bucket.this
```

**Comprobar que el bucket existe** (comandos sueltos, sustituye `<usuario>` por tu `lab_user`):

```bash
aws s3api head-bucket --bucket curso-<usuario>-data-us-east-2
aws s3 ls | grep curso-<usuario>
```

- Sin error → el bucket existe.
- `404` / `NoSuchBucket` → no existe (o ya se borró).
- `403` en `head-bucket` → prueba `aws s3 ls`; a veces lista buckets aunque otras lecturas fallen.

## Comprueba tu entendimiento

**Composición correcta**
Ejecuta `terraform plan`.
→ El nombre del bucket incluye el prefijo `curso-<usuario>-` y lleva las etiquetas comunes.

**Versionado parametrizable**
Cambia `versioning = false` al consumir el módulo y vuelve a `plan`.
→ El recurso de versionado pasa a `Suspended`.

## Reto

### 1 — Cifrado por defecto

¿Cómo añadirías cifrado en reposo al módulo sin obligar a cada consumidor a configurarlo?

<details>
<summary>Ver solución</summary>

Añade dentro del módulo un `aws_s3_bucket_server_side_encryption_configuration` con SSE-S3
(`AES256`) por defecto, opcionalmente controlado por una variable `encryption` (default `true`). El
consumidor obtiene cifrado sin conocer los detalles.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `Reference to undeclared input variable "lab_user"` | Usas `var.lab_user` en el bucket pero no la declaraste | Paso 2: añádela en `variables.tf` y en `terraform.tfvars` (mismo valor que `AWS_LAB_USER`) |
| `403 AccessDenied` al crear o borrar el bucket | `lab_user` no coincide con `AWS_LAB_USER` del rol | Alinea ambos valores (p. ej. `david.pestana`) |
| `403 AccessDenied` en `s3:GetBucketWebsite` (u otra `GetBucket*`) | Capa de permisos del lab: el provider refresca el bucket con lecturas que el rol no tiene | No es fallo de tu código; usa `terraform destroy -auto-approve -refresh=false` (igual en `apply`) |
| `BucketAlreadyExists` | Los nombres de bucket son globales en AWS | Añade sufijo único (región, cuenta o `random_id`) |
| `Unsupported argument` | Input no declarado en el módulo | Revisa las `variable` del módulo |
| El bucket queda tras la práctica | Olvidaste destruir | `terraform destroy -auto-approve -refresh=false` en `environments/dev` |
| Acceso AWS falla | Fuera de la ventana o prefijo incorrecto | Reintenta en sesión; buckets `curso-<usuario>-*` en `us-east-2` |
