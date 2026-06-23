# M07-02 — Análisis de drift

[← Página anterior](M07-01-operar-estado.md) · [Siguiente página →](../M08-terraform-cloud/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Provocar un cambio **fuera** de Terraform (en la consola de AWS) y detectarlo como drift con
`terraform plan`.

### Prerrequisitos

- Dev container (M01), credenciales activas y un recurso aplicado (puedes reusar el bucket del README/demo).

### En qué consiste

Creas un bucket con una etiqueta, la cambias a mano en la consola y observas cómo `plan` lo detecta.

### 1 — Aplica un recurso con etiqueta

**Acción:** En `labs-sandbox/m07-drift/main.tf`:

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "curso-TU-USUARIO-drift-demo"
  tags = {
    Owner = "terraform"
  }
}
```

```bash
cd labs-sandbox/m07-drift
terraform init
terraform apply
```

**Por qué:** Necesitas un recurso gestionado para luego provocar drift.
**Resultado esperado:** El bucket existe con la etiqueta `Owner = terraform`.

### 2 — Cambia algo a mano en la consola de AWS

**Acción:** En la consola de AWS → S3 → tu bucket → **Properties/Tags**, edita la etiqueta `Owner`
a `manual`.
**Por qué:** Simulas el caso real: alguien tocó la infraestructura fuera de Terraform.
**Resultado esperado:** En AWS la etiqueta vale `manual`; el estado de Terraform sigue diciendo `terraform`.

### 3 — Detecta el drift

**Acción:**

```bash
terraform plan
```

**Por qué:** `plan` compara realidad vs estado y muestra la diferencia.
**Resultado esperado:** El `plan` propone **volver** la etiqueta a `terraform` (revertir el drift).

> [!TIP]
> `terraform plan -refresh-only` te muestra el drift sin proponer cambios de tu código: útil para
> auditar qué cambió fuera antes de decidir.

### 4 — Decide: revertir o reconciliar

**Acción:** Tienes dos opciones:
- **Revertir:** `terraform apply` deja la etiqueta como en el código (`terraform`).
- **Reconciliar:** si el cambio manual era el bueno, actualiza el código a `manual` y aplica.

**Por qué:** El drift no siempre se "deshace": a veces el cambio manual es correcto y el código debe adoptarlo.
**Resultado esperado:** Realidad, estado y código vuelven a coincidir.

### 5 — Limpia

**Acción:** `terraform destroy`.
**Resultado esperado:** El bucket se elimina.

## Comprueba tu entendimiento

**El drift se detecta**
Tras el cambio manual, ejecuta `terraform plan`.
→ Muestra una diferencia en la etiqueta `Owner`.

**Reconciliación**
Tras decidir y aplicar, ejecuta `terraform plan` de nuevo.
→ Responde `No changes`.

## Reto

### 1 — Drift de borrado

¿Qué muestra `terraform plan` si alguien **borra** el bucket directamente en la consola?

<details>
<summary>Ver solución</summary>

Al refrescar, Terraform ve que el recurso ya no existe y el `plan` propone **crearlo** de nuevo
(para volver al estado deseado del código). El drift puede ser tanto un cambio como una ausencia.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `plan` no detecta el cambio | El cambio no afecta a un atributo gestionado | Cambia un atributo presente en el código (p. ej. una tag declarada) |
| `plan` quiere revertir algo correcto | El cambio manual era el bueno | Actualiza el código y aplica para reconciliar |
| Acceso AWS falla | Fuera de la ventana | Reintenta en sesión |
| El bucket queda tras la práctica | Olvidaste destruir | `terraform destroy` |
