# M08 — Terraform Cloud y estados remotos

[← Página anterior](../M07-gestion-estado/M07-02-analisis-drift.md) · [Siguiente página →](M08-01-migracion-terraform-cloud.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en el laboratorio.

## Qué aprenderás

- Por qué el estado local no sirve para equipos y qué aporta un **backend remoto**.
- Migrar el estado a **Terraform Cloud** y trabajar con **workspaces**.
- Cómo el **bloqueo (locking)** evita que dos `apply` corran a la vez.

## Teoría

| Estado local | Estado remoto (Terraform Cloud) |
|--------------|---------------------------------|
| Vive en tu disco (`terraform.tfstate`) | Vive en TFC, compartido por el equipo |
| Sin bloqueo: dos `apply` lo corrompen | **Locking** automático: un `apply` a la vez |
| Sin historial ni control de acceso | Versionado, permisos y auditoría |

Un **workspace** de TFC es un estado aislado (típicamente uno por entorno: `tfadv-dev`,
`tfadv-prod`). Las credenciales de AWS se configuran como **variables de entorno** del workspace,
no en tu disco.

> [!IMPORTANT]
> Al migrar, Terraform **sube tu estado local** a TFC. A partir de ahí, el estado de verdad vive en
> TFC: no edites el `.tfstate` local (ya no manda).

### Recuperar un estado anterior en Terraform Cloud

TFC guarda **historial de versiones** del estado en cada workspace. Si un `apply` dejó la
infraestructura en un estado indeseable:

1. En la UI → workspace → **States** → elige una versión anterior → **Download** o **Restore**.
2. Tras restaurar, ejecuta `terraform plan` desde tu entorno: debe mostrar cómo volver a la
   realidad deseada (o `No changes` si ya coincide).
3. Documenta en el PR qué versión restauraste y por qué.

> [!TIP]
> Restaurar el estado **no revierte** cambios ya hechos en AWS por sí solo: reconcilia lo que
> Terraform *cree* que existe. Si hace falta, combina restauración con `apply` o import.

## Demostración guiada

> Recorrido del formador. El backend es TFC; el `apply` toca AWS (🔴): hazlo en la sesión.

1. **Login y bloque cloud.** Tras `terraform login`, se añade el bloque `cloud { organization... }`
   apuntando al workspace.
2. **Migración del estado.** `terraform init` detecta el cambio de backend y ofrece **migrar** el
   estado local a TFC; se acepta y se comprueba en la UI que el estado ya está arriba.
3. **Credenciales en el workspace.** En la UI de TFC se añaden `AWS_ACCESS_KEY_ID`/`SECRET` como
   variables de entorno sensibles.
4. **Locking en acción.** Se lanza un `apply` y, en paralelo, se intenta otro: el segundo espera
   por el lock. Ahí se ve el valor del estado remoto.
5. **Historial de estados.** Se muestra cómo descargar o restaurar una versión anterior del estado
   desde la pestaña **States** del workspace.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M08-01 | [Migración a Terraform Cloud](M08-01-migracion-terraform-cloud.md) | Crear el workspace, migrar el estado local y aplicar desde TFC |

→ Empieza por **[M08-01 — Migración a Terraform Cloud](M08-01-migracion-terraform-cloud.md)**.
