# M06-02 — locals, condicionales y funciones

[← Página anterior](M06-02-locals-condicionales.md) · [Siguiente página →](M06-03-hcl-avanzado.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Usar `locals`, un condicional y funciones (`for`, `merge`, `lookup`) para parametrizar recursos sin
repetir código. Todo con `plan`, sin aplicar: no consume AWS.

### Prerrequisitos

- M06-01 (mismo directorio `labs-sandbox/m06`).

### En qué consiste

Calculas en `locals` qué buckets deben versionarse y generas su configuración con un `for`.

### 1 — Marca qué buckets versionar

**Acción:** Recuerda el mapa de M06-01 (cada bucket tiene `versioning`). Añade un local derivado:

```hcl
locals {
  versioned_buckets = {
    for name, cfg in local.buckets : name => cfg
    if cfg.versioning
  }
}
```

**Por qué:** Un `for` con `if` filtra el mapa sin duplicar datos.
**Resultado esperado:** `versioned_buckets` contiene solo `data`.

### 2 — Aplica versionado solo a esos

**Acción:**

```hcl
resource "aws_s3_bucket_versioning" "this" {
  for_each = local.versioned_buckets
  bucket   = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}
```

**Por qué:** Generas configuración solo para los buckets marcados, sin condicionales repetidos.
**Resultado esperado:** El `plan` añade versionado únicamente para `data`.

### 3 — Combina etiquetas con merge y lookup

**Acción:**

```hcl
locals {
  base_tags = {
    Project   = var.project
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets
  bucket   = "${local.prefix}-${each.key}"
  tags = merge(local.base_tags, {
    Role       = each.key
    Versioning = lookup(each.value, "versioning", false) ? "on" : "off"
  })
}
```

**Por qué:** `merge` combina etiquetas comunes con específicas; `lookup` lee del mapa con default seguro.
**Resultado esperado:** Cada bucket lleva etiquetas comunes + su `Role` y `Versioning`.

### 4 — Valida y revisa

**Acción:**

```bash
cd labs-sandbox/m06
terraform fmt
terraform validate
terraform plan
```

**Por qué:** Compruebas que la lógica produce lo esperado sin tocar AWS.
**Resultado esperado:** Solo `data` recibe versionado; las etiquetas reflejan el rol de cada bucket.

## Comprueba tu entendimiento

**Filtrado con for + if**
Revisa el `plan`.
→ El recurso de versionado solo existe para `this["data"]`.

**Etiquetas combinadas**
Mira las `tags` propuestas.
→ Incluyen `Project`, `ManagedBy` y un `Role` distinto por bucket.

## Reto

### 1 — Tamaño por entorno con un mapa

Quieres una clase de almacenamiento distinta por entorno (`dev`→`STANDARD`, `prod`→`STANDARD_IA`).
¿Cómo lo resolverías sin `if` anidados?

<details>
<summary>Ver solución</summary>

Define un mapa `local.storage_by_env = { dev = "STANDARD", prod = "STANDARD_IA" }` y selecciona con
`lookup(local.storage_by_env, var.environment, "STANDARD")`. Tabla de decisión en vez de
condicionales encadenados.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `Unsupported attribute` en `each.value` | El elemento no tiene esa clave | Usa `lookup(each.value, "k", default)` |
| `for` devuelve lista cuando querías mapa | Sintaxis `[for ...]` en vez de `{for k,v ...}` | Usa llaves `{ ... => ... }` para mapas |
| `merge` pierde etiquetas | Orden de argumentos | Lo específico va **después** para sobreescribir |
