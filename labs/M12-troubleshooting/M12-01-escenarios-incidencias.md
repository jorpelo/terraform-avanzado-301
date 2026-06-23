# M12-01 — Escenarios de incidencias

[← Página anterior](README.md) · [Siguiente página →](../M13-terraform-ansible/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Resolver una batería de errores preparados aplicando el método **leer → reproducir → aislar →
corregir**. Mayormente local (`validate`/`plan`).

### Prerrequisitos

- Dev container (M01). Para los escenarios de estado puede hacer falta credenciales.

### En qué consiste

Reproduces cada escenario, lees el error y lo corriges.

### 1 — Dependencia circular

**Acción:** Crea dos recursos que se referencian mutuamente y ejecuta `terraform validate`:

```hcl
resource "aws_s3_bucket" "a" {
  bucket = "curso-${var.lab_user}-cycle-a-${aws_s3_bucket.b.id}"
}
resource "aws_s3_bucket" "b" {
  bucket = "curso-${var.lab_user}-cycle-b-${aws_s3_bucket.a.id}"
}
```

**Por qué:** Reproduces el ciclo de dependencias clásico.
**Resultado esperado:** Error `Cycle: ...`. **Corrige** rompiendo la referencia (nombres independientes).

### 2 — Variable inválida

**Acción:** Declara una variable con `validation` y pásale un valor que no cumpla:

```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment debe ser dev, test o prod."
  }
}
```

```bash
terraform plan -var "environment=staging"
```

**Por qué:** Ves cómo `validation` atrapa valores incorrectos con un mensaje claro.
**Resultado esperado:** Error con tu `error_message`. **Corrige** pasando un valor válido.

### 3 — Estado bloqueado

**Acción:** Con un `apply` en curso (o un lock dejado), lanza otro `plan` en el mismo entorno.
**Por qué:** Reproduces `Error acquiring the state lock`.
**Resultado esperado:** Mensaje de lock con su ID. **Corrige** esperando o liberando el lock con cuidado.

### 4 — Error oscuro: sube el log

**Acción:** Ante un error poco claro de provider:

```bash
TF_LOG=DEBUG terraform plan 2> debug.log
# busca en debug.log la llamada que falla
unset TF_LOG
```

**Por qué:** El log detallado muestra la petición al provider que está fallando.
**Resultado esperado:** Localizas la causa en `debug.log` y apagas el log al terminar.

### 5 — Recuperar estado desde backup local

**Acción:** Tras un `apply` en un entorno de prueba, copia el backup que Terraform genera:

```bash
cp terraform.tfstate terraform.tfstate.roto   # simula corrupción
cp terraform.tfstate.backup terraform.tfstate # restaura
terraform plan
```

**Por qué:** Practica la recuperación sin depender de TFC.
**Resultado esperado:** `plan` vuelve a ser coherente con el backup restaurado.

### 6 — (Opcional) Restaurar en Terraform Cloud

**Acción:** Si usas TFC (M08), en la UI del workspace → **States** → elige una versión anterior →
**Restore**. Luego `terraform plan` desde tu máquina.
**Por qué:** Es el camino habitual en equipo cuando un apply fue demasiado lejos.
**Resultado esperado:** Entiendes la diferencia entre restaurar estado y deshacer cambios en AWS.

## Comprueba tu entendimiento

**Ciclo resuelto**
Tras corregir el escenario 1, ejecuta `terraform validate`.
→ Responde válido, sin `Cycle`.

**Validación funciona**
Pasa un `environment` inválido y luego uno válido.
→ El primero falla con tu mensaje; el segundo pasa.

## Reto

### 1 — Estado corrupto

Si el `.tfstate` se corrompe (JSON inválido), ¿qué pasos de recuperación seguirías?

<details>
<summary>Ver solución</summary>

Restaura desde el backup que Terraform deja (`*.tfstate.backup`) o desde el historial de versiones
del backend remoto (TFC guarda versiones). Si no, reconstruye con `import`. Nunca edites el JSON a
mano salvo último recurso y con copia previa.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `Cycle` | Recursos que se referencian en círculo | Rompe la referencia mutua |
| `Error acquiring the state lock` | Otra operación tiene el estado | Espera; libera el lock solo si estás seguro |
| `TF_LOG` no cambia nada | Mal escrito o no exportado | `export TF_LOG=DEBUG` (o prefijo en la línea) |
| `debug.log` enorme e ilegible | DEBUG es muy verboso | Filtra por el recurso/acción del error |
