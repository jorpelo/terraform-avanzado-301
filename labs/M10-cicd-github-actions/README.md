# M10 — CI/CD con GitHub Actions

[← Página anterior](../M09-importacion-refactorizacion/M09-02-refactor-moved.md) · [Siguiente página →](M10-01-validacion-plan-pr.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en los laboratorios (este módulo tiene tres).

## Qué aprenderás

- Aplicar CI/CD a Terraform: validar en cada PR y desplegar de forma controlada.
- Separar **plan** (en el PR) de **apply** (en el merge, con aprobación).
- Estimar el **coste** de un cambio con Infracost en el PR.

## Teoría

El principio: **el ordenador valida, las personas deciden.**

| Fase | Cuándo | Qué hace |
|------|--------|----------|
| **Validación** | En cada Pull Request | `fmt -check`, `validate`, `plan` |
| **Despliegue** | Al mergear a `main` | `apply`, normalmente tras **aprobación manual** |

GitHub Actions ejecuta *workflows* (YAML en `.github/workflows/`) disparados por eventos
(`pull_request`, `push`). Los secretos (credenciales) se guardan en **GitHub Secrets**, nunca en el
repo. Un **environment** con *required reviewers* añade la puerta de aprobación antes del `apply`.

> [!IMPORTANT]
> El `plan` en el PR es la **revisión de infraestructura**: el revisor ve exactamente qué cambiará
> antes de aprobar. Sin él, apruebas a ciegas.

## Demostración guiada

> Recorrido del formador. El `apply` toca AWS (🔴): hazlo en la sesión.

1. **Workflow de validación.** Se muestra un workflow `on: pull_request` que corre `fmt`,
   `validate` y `plan`, y publica el resultado en el PR.
2. **Secretos.** Se ven los `secrets` del repo (credenciales AWS) y cómo el workflow los inyecta
   como variables de entorno.
3. **Apply con aprobación.** Un segundo workflow `on: push` a `main` ejecuta `apply`, pero el job
   usa un **environment** protegido: queda en espera hasta que un revisor aprueba.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M10-01 | [Validación y plan en el PR](M10-01-validacion-plan-pr.md) | Workflow que corre `fmt`, `validate` y `plan` en cada Pull Request |
| M10-02 | [Apply con aprobación](M10-02-apply-aprobacion.md) | Workflow de `apply` en merge, protegido por un environment con revisor |
| M10-03 | [Infracost en el PR](M10-03-infracost-pr.md) | Publicar estimación de coste en cada Pull Request |

→ Empieza por **[M10-01 — Validación y plan en el PR](M10-01-validacion-plan-pr.md)**.
