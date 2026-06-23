# M06 — Expresiones avanzadas

[← Página anterior](../M05-versionado-modulos/M05-01-versionado-distribucion.md) · [Siguiente página →](M06-01-count-for-each.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en los laboratorios (este módulo tiene tres).

## Qué aprenderás

- Generar infraestructura dinámica con `count` y `for_each`.
- Usar `locals`, expresiones condicionales y funciones integradas.
- Usar bloques **`dynamic`**, **`try`** y **`lifecycle.precondition`** para HCL más expresivo.

## Teoría

| Mecanismo | Cuándo usarlo | Riesgo |
|-----------|---------------|--------|
| `for_each` | Conjunto de recursos con **clave estable** (mapa/set) | Bajo: cada recurso se identifica por su clave |
| `count` | On/off (`count = var.enabled ? 1 : 0`) o listas fijas | Al reordenar una lista, Terraform recrea recursos |

> [!IMPORTANT]
> **`for_each` por defecto.** Con `count` sobre una lista, si insertas un elemento al principio
> todos los índices se desplazan y Terraform recrea recursos que no cambiaron. Con `for_each` cada
> recurso se ancla a su clave y eso no pasa.

`locals` da nombre a valores calculados; los condicionales (`cond ? a : b`) y funciones (`merge`,
`lookup`, `toset`, `for`) construyen estructuras sin repetir.

## Demostración guiada

> Recorrido del formador. Todo con `plan`, sin aplicar: no consume AWS.

1. **`for_each` sobre un mapa.** A partir de un mapa de "buckets lógicos", un único bloque de
   recurso genera N buckets. En el `plan` se ven por clave (`this["logs"]`, `this["data"]`…), no
   como lista anónima: la identidad es estable.
2. **`count` para on/off.** Se muestra el patrón `count = var.enabled ? 1 : 0` y por qué `count`
   sobre listas reordenables es frágil.
3. **`locals`, condicionales y funciones.** Se parametriza con `locals` y un `for` con condición
   (versionar solo los buckets marcados), y se observa el `plan`.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M06-01 | [count y for_each](M06-01-count-for-each.md) | Generar recursos con `for_each` sobre un mapa y un recurso condicional con `count` |
| M06-02 | [locals, condicionales y funciones](M06-02-locals-condicionales.md) | Parametrizar con `locals`, `for` con condición y funciones de manipulación |
| M06-03 | [HCL avanzado](M06-03-hcl-avanzado.md) | `dynamic`, `try` y preconditions para entradas seguras |

→ Empieza por **[M06-01 — count y for_each](M06-01-count-for-each.md)**.
