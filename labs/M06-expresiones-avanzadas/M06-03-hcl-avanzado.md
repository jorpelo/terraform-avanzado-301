# M06-03 — HCL avanzado: dynamic, try y preconditions

[← Página anterior](M06-02-locals-condicionales.md) · [Siguiente página →](../M07-gestion-estado/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Usar bloques **`dynamic`**, la función **`try`** y **`lifecycle.precondition`** para HCL más
expresivo y seguro. Todo con `plan`/`validate`, sin aplicar: no consume AWS.

### Prerrequisitos

- M06-01 y M06-02 (directorio `labs-sandbox/m06`).

### En qué consiste

Parametrizas reglas opcionales con `dynamic`, toleras mapas incompletos con `try` y fallas pronto
con preconditions cuando la entrada no es válida.

### 1 — Reglas opcionales con dynamic

**Acción:** Parte del mapa de buckets de M06-01. Añade un bloque dinámico para lifecycle (solo si
`cfg.expire_days > 0`):

```hcl
variable "buckets" {
  type = map(object({
    versioning  = bool
    expire_days = optional(number, 0)
  }))
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  dynamic "rule" {
    for_each = each.value.expire_days > 0 ? [each.value] : []
    content {
      id     = "expire-${each.key}"
      status = "Enabled"
      expiration {
        days = rule.value.expire_days
      }
    }
  }
}
```

**Por qué:** `dynamic` evita duplicar bloques enteros cuando solo algunos elementos los necesitan.
**Resultado esperado:** En `plan`, solo los buckets con `expire_days > 0` muestran reglas.

### 2 — Valores opcionales con try

**Acción:** En `locals`, deriva etiquetas sin asumir que todas las claves existen:

```hcl
locals {
  bucket_tags = {
    for name, cfg in var.buckets : name => merge(
      { ManagedBy = "terraform" },
      try(cfg.tags, {})
    )
  }
}
```

**Por qué:** `try` devuelve un fallback si la expresión falla (p. ej. atributo ausente).
**Resultado esperado:** Buckets sin `tags` en el mapa siguen recibiendo `ManagedBy`.

### 3 — Falla pronto con precondition

**Acción:** Añade una comprobación en el recurso bucket:

```hcl
resource "aws_s3_bucket" "this" {
  for_each = var.buckets
  bucket   = "curso-${var.lab_user}-${each.key}"

  lifecycle {
    precondition {
      condition     = can(regex("^curso-", "curso-${var.lab_user}-${each.key}"))
      error_message = "Los buckets del curso deben usar el prefijo curso-<usuario>-."
    }
  }
}
```

**Por qué:** Las preconditions se evalúan en `plan` y evitan applies inválidos.
**Resultado esperado:** Si cambias el prefijo a algo no permitido, `plan` falla con tu mensaje.

### 4 — Valida sin aplicar

**Acción:**

```bash
cd labs-sandbox/m06
terraform validate
terraform plan
```

**Por qué:** Confirmas sintaxis, preconditions y el efecto de `dynamic`/`try`.
**Resultado esperado:** `validate` OK; `plan` coherente con tus entradas.

## Comprueba tu entendimiento

**dynamic condicional**
Pon `expire_days = 0` en un bucket y ejecuta `plan`.
→ Ese bucket no incluye regla de expiración.

**precondition**
Cambia temporalmente el prefijo del bucket a uno no permitido.
→ `plan` falla con el `error_message` definido.

## Reto

### 1 — Varios bloques dynamic

¿Cómo añadirías transición a Glacier solo cuando `cfg.glacier_days > 0`, reutilizando el mismo
patrón `dynamic "rule"`?

<details>
<summary>Ver solución</summary>

Segundo bloque `dynamic "rule"` con `for_each = cfg.glacier_days > 0 ? [cfg] : []` y dentro un
`transition { days = ... storage_class = "GLACIER" }`. Cada `dynamic` genera cero o un bloque hijo.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `Unsupported block type` | `dynamic` mal anidado | El `dynamic` va donde iría el bloque repetido |
| `try` no evita el error | La expresión falla antes del fallback | Envuelve solo la parte que puede fallar |
| Precondition en apply, no en plan | Sintaxis incorrecta | Debe ir dentro de `lifecycle { precondition { ... } }` |
| `optional()` no reconocido | Terraform antiguo | Usa el dev container del curso (≥ 1.15) |
