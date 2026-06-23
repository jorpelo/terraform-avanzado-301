# M11 — Seguridad y gestión de secretos

[← Página anterior](../M10-cicd-github-actions/M10-02-apply-aprobacion.md) · [Siguiente página →](M11-01-oidc.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en los laboratorios (este módulo tiene dos).

## Qué aprenderás

- Eliminar credenciales estáticas del pipeline con **OIDC GitHub ↔ AWS**.
- Aplicar el principio de **mínimo privilegio** en los roles de IAM.
- Tratar variables sensibles correctamente en Terraform.

## Teoría

**OIDC** permite que GitHub Actions **asuma un rol de AWS** presentando un token de identidad
firmado, sin guardar claves. AWS confía en el emisor de GitHub y entrega credenciales **temporales**.

| Sin OIDC | Con OIDC |
|----------|----------|
| Claves estáticas en GitHub Secrets | Sin claves: token efímero por ejecución |
| Si se filtran, valen hasta rotarlas | Caducan en minutos; alcance acotado |

Un rol de IAM tiene dos caras que conviene no confundir:

| Política | Responde a |
|----------|------------|
| **Trust policy** | ¿**Quién** puede asumir el rol? (aquí, el repo/rama de GitHub vía OIDC) |
| **Permission policy** | ¿**Qué** puede hacer quien lo asume? (mínimo privilegio) |

> [!IMPORTANT]
> Empieza por permisos **mínimos** y amplía cuando un `apply` falle por falta de permiso. Al revés
> (dar `*` y recortar) casi nadie lo recorta nunca.

## Demostración guiada

> Recorrido del formador. Crea IAM real (🔴 AWS): hazlo en la sesión.

1. **Proveedor OIDC y rol pre-creados.** El OIDC de GitHub ya existe en la cuenta; cada alumno tiene
   un rol `lab-ci-<usuario>` con trust policy hacia su fork.
2. **Workflow sin claves.** El workflow usa `aws-actions/configure-aws-credentials` con
   `role-to-assume` y `permissions: id-token: write`; ya no hay `AWS_ACCESS_KEY_ID`.
3. **Mínimo privilegio.** Se parte de una **permission policy** mínima y se observa cómo un `apply`
   falla si falta un permiso, para añadir solo el que hace falta.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M11-01 | [OIDC GitHub ↔ AWS](M11-01-oidc.md) | Usar el rol `lab-ci-<usuario>` pre-creado y quitar claves estáticas del pipeline |
| M11-02 | [Mínimo privilegio](M11-02-minimo-privilegio.md) | Ajustar la permission policy del rol al mínimo necesario |

→ Empieza por **[M11-01 — OIDC GitHub ↔ AWS](M11-01-oidc.md)**.
