# M04 — Módulos reutilizables

[← Página anterior](../M03-git-iac/M03-01-flujo-pull-request.md) · [Siguiente página →](M04-01-modulos-naming-tagging.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en los laboratorios (este módulo tiene dos).

## Qué aprenderás

- Qué es un módulo y cuándo conviene crearlo.
- Diseñar módulos con **inputs** (variables) y **outputs** bien definidos.
- Encapsular lógica reutilizable: naming corporativo, etiquetado y un S3 parametrizable.

## Teoría

Un módulo es un directorio con archivos `.tf` que define **entradas** (`variable`), **lógica**
(recursos/`locals`) y **salidas** (`output`). Quien lo usa no necesita leer su interior: le pasa
inputs y recibe outputs.

| Pieza | Rol |
|-------|-----|
| `variable` | Input: lo que el módulo necesita saber |
| `output` | Lo que el módulo devuelve para que otros lo usen |
| `source` | Dónde vive el módulo (ruta local, Git, registry) |

> [!NOTE]
> **Empieza mínimo.** Un módulo con 20 inputs es difícil de usar. Expón solo lo que de verdad
> cambia entre usos; el resto, valores por defecto.

Los módulos se **componen**: un módulo de naming produce el prefijo, el de tagging produce las
etiquetas, y ambos alimentan al de S3.

## Demostración guiada

> Recorrido del formador. Diseño y `plan` son locales; el `apply` del bucket es opcional (🟡 AWS).

1. **De recurso suelto a módulo.** Se parte de un bucket "a mano" y se extrae a `modules/s3` con
   sus inputs/outputs, mostrando cómo se reduce la duplicación.
2. **Composición.** En `environments/dev` se ve cómo `module.naming.prefix` y `module.tags.tags`
   alimentan a `module.bucket`. El `terraform plan` muestra el nombre y etiquetas resultantes.
3. **Interfaz mínima.** Se discute qué inputs exponer (lo que cambia) y qué resolver con defaults.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M04-01 | [Módulos de naming y tagging](M04-01-modulos-naming-tagging.md) | Crear dos módulos base y consumirlos desde el entorno |
| M04-02 | [Módulo S3 parametrizable](M04-02-modulo-s3-parametrizable.md) | Encapsular un bucket con versionado y componerlo con naming/tagging |

→ Empieza por **[M04-01 — Módulos de naming y tagging](M04-01-modulos-naming-tagging.md)**.
