# M12 — Troubleshooting y depuración

[← Página anterior](../M11-seguridad-secretos/M11-02-minimo-privilegio.md) · [Siguiente página →](M12-01-escenarios-incidencias.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en el laboratorio.

## Qué aprenderás

- Un **método** para diagnosticar errores de Terraform en vez de ir a ciegas.
- Interpretar mensajes de error y activar el log detallado con `TF_LOG`.
- Resolver incidencias típicas: dependencias circulares, drift, estado, variables.
- **Recuperar** un estado anterior (local backup o historial de TFC).

## Teoría

Método en cuatro pasos: **leer el error → reproducir → aislar → corregir**. Casi todos los errores
de Terraform dicen el recurso, el atributo y a menudo la causa.

| Herramienta | Para qué |
|-------------|----------|
| `terraform validate` | Errores de sintaxis y referencias antes de aplicar |
| `terraform plan` | Ver qué cambiaría y detectar drift |
| `TF_LOG=DEBUG` | Log detallado (incluye llamadas al provider) |
| `terraform state list/show` | Comprobar qué hay realmente en el estado |

| Incidencia | Pista típica |
|------------|--------------|
| Dependencia circular | `Cycle: a → b → a` |
| Recurso inconsistente | `Provider produced inconsistent result` |
| Estado/lock | `Error acquiring the state lock` |
| Variable incorrecta | `Invalid value for variable` |
| Estado corrupto / apply erróneo | Restaurar `.tfstate.backup` o versión en TFC **States** |

> [!WARNING]
> `TF_LOG=DEBUG` es muy verboso y puede incluir datos sensibles. Úsalo para diagnosticar y
> desactívalo después (`unset TF_LOG`); no lo dejes en pipelines.

## Demostración guiada

> Recorrido del formador. Mayormente `validate`/`plan`: poco o ningún consumo de AWS.

1. **Romper a propósito.** Se introduce una dependencia circular (dos recursos que se referencian)
   y se lee el mensaje `Cycle`, mostrando cómo localizar el ciclo.
2. **Leer el error.** Se interpreta un `Invalid value for variable` y se corrige con `validation`.
3. **Subir el detalle.** Se activa `TF_LOG=DEBUG` para un error oscuro de provider y se enseña a
   encontrar la llamada que falla, y luego a apagarlo.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M12-01 | [Escenarios de incidencias](M12-01-escenarios-incidencias.md) | Resolver una batería de errores preparados aplicando el método |

→ Empieza por **[M12-01 — Escenarios de incidencias](M12-01-escenarios-incidencias.md)**.
