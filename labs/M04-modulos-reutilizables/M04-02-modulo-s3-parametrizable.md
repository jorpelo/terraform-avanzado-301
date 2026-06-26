# M04-02 — Módulo S3 parametrizable

[← Página anterior](M04-01-modulos-naming-tagging.md) · [Siguiente página →](../M05-versionado-modulos/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Encapsular un bucket S3 (con versionado opcional) en un módulo y componerlo con los de naming y
tagging. Diseño y `plan` son locales; el `apply` es opcional.

### Prerrequisitos

- Haber hecho M04-01 (módulos `naming` y `tags` ya consumidos en `environments/dev`).

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

### 2 — Compón con naming y tagging

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

### 3 — Inicializa y planifica

**Acción:**

```bash
cd environments/dev
terraform init
terraform plan
```

**Por qué:** Compruebas qué se crearía sin aplicar todavía.
**Resultado esperado:** `plan` propone crear el bucket con nombre y etiquetas correctos.

### 4 — (Opcional) Aplica y destruye

**Acción:**

```bash
terraform apply
# ... revisa el bucket ...
terraform destroy
```

**Por qué:** Si quieres verlo real, créalo y elimínalo en la misma sesión.
**Resultado esperado:** El bucket se crea y luego se destruye.

> [!WARNING]
> Este paso crea un recurso real en AWS. Hazlo dentro de la ventana de clase y **destruye al
> terminar**. Si solo practicas el diseño, quédate en `plan`.

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
| `BucketAlreadyExists` | Los nombres de bucket son globales en AWS | Añade sufijo único (región, cuenta o `random_id`) |
| `Unsupported argument` | Input no declarado en el módulo | Revisa las `variable` del módulo |
| El bucket queda tras la práctica | Olvidaste destruir | `terraform destroy` en `environments/dev` |
| Acceso AWS falla | Fuera de la ventana | Reintenta en sesión (o quédate en `plan`) |
