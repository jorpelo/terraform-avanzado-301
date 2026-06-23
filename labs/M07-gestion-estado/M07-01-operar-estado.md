# M07-01 — Operar el estado

[← Página anterior](README.md) · [Siguiente página →](M07-02-analisis-drift.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Inspeccionar el estado y **renombrar un recurso con `state mv`** sin que Terraform lo recree.

### Prerrequisitos

- Dev container (M01), credenciales activas (ventana AWS) y región **us-east-2**.

> [!TIP]
> Sustituye `TU-USUARIO` por tu `AWS_LAB_USER` (p. ej. `david.pestana`). Los buckets deben
> empezar por `curso-<usuario>-`.

### En qué consiste

Aplicas un recurso mínimo, lo inspeccionas, lo renombras en el código y reconcilias el estado con
`state mv` para que el `plan` quede limpio.

### 1 — Aplica un recurso mínimo

**Acción:** En `labs-sandbox/m07/main.tf` define un bucket y aplica:

```hcl
resource "aws_s3_bucket" "data" {
  bucket = "curso-TU-USUARIO-state-demo"
}
```

```bash
cd labs-sandbox/m07
terraform init
terraform apply
```

**Por qué:** Necesitas un recurso real en el estado para operarlo.
**Resultado esperado:** El bucket existe y aparece en el estado.

### 2 — Inspecciona el estado

**Acción:**

```bash
terraform state list
terraform state show aws_s3_bucket.data
```

**Por qué:** Ves qué hay registrado y los atributos reales del recurso.
**Resultado esperado:** `state list` muestra `aws_s3_bucket.data`; `state show` sus atributos.

### 3 — Renombra el recurso en el código

**Acción:** Cambia el nombre lógico (no el bucket real) de `data` a `primary`:

```hcl
resource "aws_s3_bucket" "primary" {
  bucket = "curso-TU-USUARIO-state-demo"
}
```

```bash
terraform plan
```

**Por qué:** Quieres ver qué cree Terraform que debe hacer ante el renombrado.
**Resultado esperado:** El `plan` propone **destruir** `data` y **crear** `primary` (no es lo que queremos).

### 4 — Reconcilia con state mv

**Acción:**

```bash
terraform state mv aws_s3_bucket.data aws_s3_bucket.primary
terraform plan
```

**Por qué:** `state mv` mueve el recurso en el estado sin tocar AWS; así el código y el estado vuelven a casar.
**Resultado esperado:** `plan` ahora dice **No changes**: el recurso real no se ha tocado.

### 5 — Limpia

**Acción:** `terraform destroy`.
**Por qué:** No dejes recursos tras la práctica.
**Resultado esperado:** El bucket se elimina.

> [!WARNING]
> Crea y destruye dentro de la ventana de clase.

## Comprueba tu entendimiento

**Renombrado sin recrear**
Tras `state mv`, ejecuta `terraform plan`.
→ Responde `No changes`.

**`mv` no toca AWS**
Compara el nombre del bucket real antes y después de `state mv`.
→ Es el mismo: solo cambió la dirección lógica en el estado.

## Reto

### 1 — `rm` vs `destroy`

Quieres dejar de gestionar el bucket con Terraform pero **sin** borrarlo en AWS. ¿Qué comando usas
y qué pasa en el siguiente `plan`?

<details>
<summary>Ver solución</summary>

`terraform state rm aws_s3_bucket.primary`: lo saca del estado pero el bucket sigue en AWS. El
siguiente `plan` ya no lo conoce (no propone destruirlo). `destroy` sí lo eliminaría.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `plan` quiere recrear tras renombrar | No usaste `state mv` | Mueve la dirección con `state mv <old> <new>` |
| `state mv` falla con direcciones | Sintaxis de la dirección | Copia la dirección exacta de `state list` |
| Borraste el recurso por error | Usaste `destroy`/`rm` sin querer | `rm` solo olvida; `destroy` borra: revisa cuál usaste |
| Acceso AWS falla | Fuera de la ventana | Reintenta en sesión |
