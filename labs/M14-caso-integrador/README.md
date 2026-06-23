# M14 — Caso práctico integrador

[← Página anterior](../M13-terraform-ansible/M13-02-configuracion-ansible.md) · [Siguiente página →](M14-01-plataforma-integradora.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero un **repaso** de cómo encajan las piezas, luego la
> **demostración guiada** del recorrido final, y después **construyes tú** la plataforma completa.

## Qué aprenderás

- Integrar todo lo del curso en un único repositorio funcional.
- Tomar decisiones de arquitectura combinando módulos, entornos, estado remoto, CI/CD y seguridad.

## Teoría — cómo encaja todo

Este módulo no introduce conceptos nuevos: **conecta** los anteriores. El repositorio final reúne:

| Pieza | De dónde viene |
|-------|----------------|
| Estructura multi-entorno | M02 |
| Módulos reutilizables y versionados | M04, M05 |
| Expresiones dinámicas | M06 |
| Estado remoto en Terraform Cloud | M07, M08 |
| Refactor sin recrear | M09 |
| Pipeline CI/CD con aprobación | M10 |
| OIDC y mínimo privilegio | M11 |
| Integración con Ansible | M13 |

> [!IMPORTANT]
> El objetivo no es "que funcione" sino que el repositorio quede **mantenible**: legible, con el
> flujo de PR/plan/apply y sin credenciales estáticas. Es la base de tus futuros proyectos.

## Demostración guiada

> Recorrido del formador por el repositorio de referencia (sin reconstruirlo en vivo).

1. **Mapa del repo.** Se recorre la estructura final: `environments/`, `modules/`,
   `.github/workflows/`, y cómo se relacionan.
2. **Flujo de un cambio.** Se sigue un cambio real: rama → PR (plan automático) → revisión → merge →
   apply con aprobación, todo con OIDC.
3. **Criterios de calidad.** Checklist de entrega: módulos versionados, estado en TFC, pipeline
   verde, OIDC sin claves, región `us-east-2`, prefijos `curso-<usuario>-*`, `tflint` y (opcional)
   comentario Infracost en PR.

## Ahora construye tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M14-01 | [Plataforma integradora](M14-01-plataforma-integradora.md) | Ensamblar el repositorio completo aplicando todo lo aprendido |

→ Empieza por **[M14-01 — Plataforma integradora](M14-01-plataforma-integradora.md)**.
