# M09-01 — Importar recursos existentes

[← Página anterior](README.md) · [Siguiente página →](M09-02-refactor-moved.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Crear un bucket "a mano" y traerlo bajo gestión de Terraform con `import`, dejando el `plan` limpio.

### Prerrequisitos

- Dev container (M01) y credenciales activas (ventana AWS).

### En qué consiste

Creas un recurso fuera de Terraform, escribes su código, lo importas al estado y ajustas hasta que
`plan` no proponga cambios.

### 1 — Crea un bucket fuera de Terraform

**Acción:**

```bash
aws --profile lab s3api create-bucket --bucket curso-${AWS_LAB_USER}-import-demo \
  --region us-east-2 \
  --create-bucket-configuration LocationConstraint=us-east-2
```

**Por qué:** Simulas un recurso preexistente que aún no conoce Terraform.
**Resultado esperado:** El bucket existe en AWS pero no en ningún estado de Terraform.

### 2 — Escribe el código del recurso

**Acción:** En `labs-sandbox/m09/main.tf`:

```hcl
resource "aws_s3_bucket" "imported" {
  bucket = "curso-TU-USUARIO-import-demo"
}
```

**Por qué:** `import` trae el recurso al estado, pero el código debes escribirlo tú.
**Resultado esperado:** Hay un bloque `resource` que describe el bucket.

### 3 — Importa el recurso

**Acción:**

```bash
cd labs-sandbox/m09
terraform init
terraform import aws_s3_bucket.imported curso-TU-USUARIO-import-demo
```

**Por qué:** Vinculas el recurso real con la dirección del código en el estado.
**Resultado esperado:** `Import successful!` y el recurso aparece en `terraform state list`.

> [!TIP]
> En Terraform moderno puedes usar el bloque `import { to = ..., id = ... }` en el código, que es
> versionable y se aplica con `plan`/`apply`. El comando `terraform import` es el método clásico.

### 4 — Ajusta hasta que el plan quede limpio

**Acción:**

```bash
terraform plan
```

**Por qué:** Si el código no refleja la realidad, `plan` propondrá cambios; ajústalo hasta `No changes`.
**Resultado esperado:** `plan` responde **No changes** (código y realidad coinciden).

### 5 — Limpia

**Acción:** `terraform destroy`.
**Resultado esperado:** El bucket se elimina.

## Comprueba tu entendimiento

**Recurso bajo gestión**
Ejecuta `terraform state list`.
→ Aparece `aws_s3_bucket.imported`.

**Sin diferencias**
Ejecuta `terraform plan`.
→ Responde `No changes`.

## Reto

### 1 — Importar muchos recursos

Te piden importar 20 buckets existentes. ¿Cómo lo abordarías sin escribir 20 imports a mano uno a uno?

<details>
<summary>Ver solución</summary>

Usa bloques `import` con `for_each` (Terraform ≥ 1.5) sobre un mapa de buckets, o genera el código
con `terraform plan -generate-config-out=...`, que produce el HCL de los recursos importados para
revisarlo y ajustarlo.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `Resource already managed` | Ya estaba en el estado | Revisa `state list` antes de importar |
| `plan` propone cambios tras importar | El código no casa con la realidad | Ajusta atributos hasta `No changes` |
| `import` pide un ID con formato | Cada recurso tiene su formato de ID | Consulta la doc del recurso (para S3 es el nombre del bucket) |
| Acceso AWS falla | Fuera de la ventana | Reintenta en sesión |
