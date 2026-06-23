# M09-02 — Refactor con moved

[← Página anterior](M09-01-importar-recursos.md) · [Siguiente página →](../M10-cicd-github-actions/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Renombrar un recurso y luego moverlo dentro de un módulo usando bloques `moved`, **sin recrear**
nada y sin comandos manuales.

### Prerrequisitos

- Dev container (M01) y credenciales activas (ventana AWS).

### En qué consiste

Aplicas un recurso, lo renombras con un bloque `moved`, y después lo encapsulas en un módulo con
otro `moved`.

### 1 — Aplica un recurso

**Acción:** En `labs-sandbox/m09-moved/main.tf`:

```hcl
resource "aws_s3_bucket" "old_name" {
  bucket = "curso-TU-USUARIO-moved-demo"
}
```

```bash
cd labs-sandbox/m09-moved
terraform init
terraform apply
```

**Por qué:** Necesitas un recurso gestionado para refactorizarlo.
**Resultado esperado:** El bucket existe y está en el estado como `aws_s3_bucket.old_name`.

### 2 — Renombra con un bloque moved

**Acción:** Cambia el nombre lógico y añade el bloque `moved`:

```hcl
resource "aws_s3_bucket" "new_name" {
  bucket = "curso-TU-USUARIO-moved-demo"
}

moved {
  from = aws_s3_bucket.old_name
  to   = aws_s3_bucket.new_name
}
```

```bash
terraform plan
```

**Por qué:** `moved` le dice a Terraform "es el mismo recurso, solo cambió la dirección".
**Resultado esperado:** `plan` indica el movimiento y **No changes** en infraestructura (no destruye/crea).

### 3 — Aplica el movimiento

**Acción:** `terraform apply`.
**Por qué:** El refactor se aplica como cualquier cambio de código, revisable en un PR.
**Resultado esperado:** El recurso queda como `new_name` sin recrearse.

### 4 — Mueve el recurso a un módulo

**Acción:** Crea `modules/bucket/main.tf` con el recurso y, en el raíz, sustitúyelo por:

```hcl
module "bucket" {
  source = "./modules/bucket"
}

moved {
  from = aws_s3_bucket.new_name
  to   = module.bucket.aws_s3_bucket.this
}
```

```bash
terraform plan
terraform apply
```

**Por qué:** `moved` también encapsula recursos dentro de módulos sin recrearlos.
**Resultado esperado:** El recurso pasa a `module.bucket...` y el `plan` no propone recrear.

### 5 — Limpia

**Acción:** `terraform destroy`.
**Resultado esperado:** El bucket se elimina.

## Comprueba tu entendimiento

**Renombrado sin recrear**
Tras aplicar el `moved`, revisa el `plan`.
→ No hay `destroy`/`create`, solo el movimiento.

**Dentro del módulo**
Ejecuta `terraform state list`.
→ El recurso aparece como `module.bucket.aws_s3_bucket.this`.

## Reto

### 1 — moved vs state mv

Ya hiciste `state mv` en M07. ¿Por qué `moved` suele ser mejor en un equipo?

<details>
<summary>Ver solución</summary>

`moved` vive en el **código**: se revisa en el PR, queda documentado y se aplica automáticamente
para todos. `state mv` es un comando manual que cada persona tendría que ejecutar en su entorno y no
deja rastro en el repositorio.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `plan` quiere destruir y crear | Falta el bloque `moved` o las direcciones no casan | Revisa `from`/`to` con las direcciones exactas |
| `Moved object does not exist` | La dirección `from` no está en el estado | Comprueba `state list` |
| El recurso se recrea al meterlo en módulo | No actualizaste el `moved` a `module.x...` | Apunta `to` a la dirección dentro del módulo |
| Acceso AWS falla | Fuera de la ventana | Reintenta en sesión |
