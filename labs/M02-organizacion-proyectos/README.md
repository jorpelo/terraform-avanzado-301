# M02 — Organización profesional de proyectos

[← Página anterior](../M01-preparacion-entorno/M01-01-entorno-verificado.md) · [Siguiente página →](M02-01-estructura-multientorno.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en el laboratorio.

## Qué aprenderás

- Cómo estructurar un repositorio Terraform pensado para **varios entornos** (dev/test/prod).
- Cómo separar lo común del código de lo que cambia por entorno (**variables**).
- Convenciones de **nomenclatura** y buenas prácticas organizativas.

## Teoría

La idea central: **una sola receta (código), varias despensas (variables)**. El código que
describe la infraestructura es el mismo; lo que cambia por entorno son los valores (tamaños,
nombres, número de recursos), que viven en archivos `*.tfvars` separados.

| Archivo | Qué contiene |
|---------|--------------|
| `main.tf` | Los recursos y la lógica (igual en todos los entornos) |
| `variables.tf` | La **declaración** de las variables (qué se puede parametrizar) |
| `terraform.tfvars` | Los **valores** concretos de ese entorno |

> [!NOTE]
> **No confundas declarar con asignar.** `variables.tf` declara que existe una variable
> `environment`; `terraform.tfvars` le da el valor `"dev"`. Lo primero es la forma; lo segundo, el contenido.

Una convención de **nomenclatura** consistente (p. ej. `curso-<usuario>-<recurso>` en AWS y
`proyecto-entorno` en variables internas) evita choques entre alumnos y hace el inventario legible.

### Definition of Done (DoD) de un cambio IaC

Antes de mergear un PR de infraestructura, comprueba:

- [ ] `terraform fmt -check` y `validate` en verde
- [ ] `plan` revisado (qué crea/modifica/destruye)
- [ ] Nombres AWS con prefijo `curso-<tu-usuario>-*`
- [ ] Región `us-east-2` (salvo indicación contraria)
- [ ] Tags mínimas (`Environment`, `ManagedBy`, etc.)
- [ ] Sin secretos en el código; credenciales fuera del repo
- [ ] Recursos efímeros de lab: `destroy` al terminar la sesión

## Demostración guiada

> Recorrido del formador. Trabajo local (editor + `terraform`), no consume AWS.

1. **Recorrido por la estructura.** En el explorador se ve una carpeta `environments/` con una
   subcarpeta por entorno (`dev`, `test`, `prod`), cada una con su `terraform.tfvars`:

```text
environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── test/
│   └── …
└── prod/
    └── …
```

2. **Misma receta, distinta despensa.** Se muestra cómo el mismo `main.tf` produce nombres
   distintos (`tfadv-dev`, `tfadv-prod`) solo cambiando el `terraform.tfvars`.
3. **Validación local.** `terraform fmt` deja el estilo canónico e `init -backend=false` +
   `validate` confirman que la configuración es coherente sin necesitar credenciales.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M02-01 | [Estructura multi-entorno](M02-01-estructura-multientorno.md) | Montar un layout dev/test/prod con variables por entorno y validarlo |

→ Empieza por **[M02-01 — Estructura multi-entorno](M02-01-estructura-multientorno.md)**.
