# M14-01 — Plataforma integradora

[← Página anterior](README.md) · [Siguiente página →](../../README.md)

> Práctica del módulo. El repaso y la demo están en el [README del módulo](README.md).

### Objetivo

Ensamblar un repositorio Terraform completo y mantenible que combine todo lo del curso: multi-entorno,
módulos versionados, estado en TFC, pipeline con aprobación, OIDC e integración con Ansible.

### Prerrequisitos

- Haber completado M01–M13. Credenciales activas (ventana AWS) para los `apply`.

### En qué consiste

Trabajas por incrementos (un PR por bloque), validando con el pipeline en cada paso, hasta tener la
plataforma funcionando de punta a punta.

### Checklist de entrega (DoD)

- [ ] Región AWS `us-east-2`; recursos con prefijo `curso-<AWS_LAB_USER>-*`
- [ ] `terraform fmt -check`, `validate` y `tflint` en CI
- [ ] Workspaces TFC por entorno; historial de estados accesible
- [ ] PR con `plan`; merge con `apply` + aprobación manual
- [ ] OIDC con rol `lab-ci-<usuario>` (sin claves estáticas)
- [ ] (Opcional) Infracost comentando coste en PR
- [ ] `destroy` ejecutado al cerrar la práctica

### 1 — Estructura y módulos

**Acción:** Parte de `environments/{dev,prod}` y consume los módulos `naming`, `tagging` y `s3`
**por versión** (`?ref=vX.Y.Z`).
**Por qué:** Reúne M02, M04 y M05: base organizada y reutilizable.
**Resultado esperado:** Ambos entornos `validate` y `plan` sin errores.

### 2 — Estado remoto

**Acción:** Configura un workspace de TFC por entorno (`tfadv-dev`, `tfadv-prod`) y migra el estado.
**Por qué:** Reúne M07–M08: estado compartido con locking.
**Resultado esperado:** Los estados viven en TFC; el locking funciona.

### 3 — Pipeline con OIDC y aprobación

**Acción:** Añade los workflows de `plan` (en PR) y `apply` (en merge, environment protegido) usando
**OIDC** (sin claves).
**Por qué:** Reúne M10–M11: despliegue controlado y seguro.
**Resultado esperado:** Un PR dispara `plan`; el merge espera aprobación y aplica con rol asumido.

### 4 — Capa de cómputo + Ansible

**Acción:** Añade una EC2 (free tier) y un playbook de Ansible que la configure, con el inventario
generado desde los outputs.
**Por qué:** Reúne M13: provisión + configuración separadas.
**Resultado esperado:** Tras el flujo, el servicio responde por HTTP.

### 5 — Refactor controlado

**Acción:** Haz un refactor (renombrar o mover un recurso a módulo) con un bloque `moved`, vía PR.
**Por qué:** Reúne M09: evolucionar sin recrear ni romper.
**Resultado esperado:** El `plan` del PR muestra el movimiento, no destrucción.

### 6 — Limpieza

**Acción:** `terraform destroy` (o workflow de destroy) en los entornos con recursos reales.
**Por qué:** Cierra la sesión sin dejar coste.
**Resultado esperado:** No quedan recursos activos en AWS.

> [!WARNING]
> Hay recursos reales (EC2, IAM, S3). Trabaja dentro de la ventana y **destruye al terminar**.

## Comprueba tu entendimiento

**Pipeline de punta a punta**
Abre un PR con un cambio.
→ Corre `plan`; al mergear, el `apply` espera aprobación y luego aplica con OIDC.

**Sin claves estáticas**
Revisa los Secrets del repo.
→ No hay credenciales AWS; el pipeline funciona por rol asumido.

**Repositorio mantenible**
Recorre la estructura final.
→ Entornos separados, módulos versionados, estado en TFC, workflows claros.

## Reto

### 1 — Un segundo entorno sin duplicar

Añade `prod` reutilizando los mismos módulos y workflows, cambiando solo variables y workspace.
¿Qué tienes que tocar y qué **no**?

<details>
<summary>Ver solución</summary>

Tocas: el `terraform.tfvars` de `prod`, el `cloud { workspaces { name } }` y, si acaso, el filtro de
environment del workflow. **No** tocas los módulos ni la lógica: misma receta, distinta despensa.
Esa es la prueba de que la arquitectura es correcta.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| El pipeline falla en `prod` pero no en `dev` | Diferencias de permisos o variables | Revisa el rol y los `tfvars` de prod |
| `plan` propone recrear tras refactor | Falta `moved` | Añade el bloque con `from`/`to` correctos |
| Recursos olvidados generan coste | No destruiste | `terraform destroy` en cada entorno |
| Acceso AWS falla | Fuera de la ventana | Reintenta en sesión |
