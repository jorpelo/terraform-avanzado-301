# M10-03 — Estimación de coste con Infracost en el PR

[← Página anterior](M10-02-apply-aprobacion.md) · [Siguiente página →](../M11-seguridad-secretos/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Añadir **Infracost** al pipeline para que cada Pull Request muestre una **estimación de coste**
antes del merge.

### Prerrequisitos

- M10-01 (workflow de plan en PR).
- Cuenta gratuita en [Infracost Cloud](https://www.infracost.io/) y API key.

### En qué consiste

Instalas Infracost en el workflow, generas un desglose de coste del `plan` y lo publicas como
comentario en el PR.

### 1 — Registra la API key

**Acción:** En GitHub → **Settings → Secrets → Actions**, crea `INFRACOST_API_KEY` con tu clave.
**Por qué:** Infracost necesita autenticación para publicar el comentario en el PR.
**Resultado esperado:** El secreto existe en el repositorio.

### 2 — Extiende el workflow de plan

**Acción:** Añade pasos tras `terraform plan` en `.github/workflows/terraform-plan.yml`:

```yaml
      - name: Setup Infracost
        uses: infracost/actions/setup@v3
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}

      - name: Generar coste del plan
        run: |
          terraform plan -out=tfplan.binary
          terraform show -json tfplan.binary > plan.json
          infracost breakdown --path plan.json --format json --out-file infracost.json

      - name: Publicar comentario en el PR
        uses: infracost/actions/comment@v1
        with:
          path: infracost.json
          behavior: update
```

**Por qué:** El comentario da visibilidad FinOps antes de aprobar infraestructura.
**Resultado esperado:** El workflow incluye los tres pasos nuevos.

### 3 — Dispara un PR de prueba

**Acción:** Abre un PR que cambie un recurso con coste (p. ej. añadir un bucket o subir
`instance_type`).
**Por qué:** Necesitas un `plan` real para que Infracost calcule diferencias.
**Resultado esperado:** El bot comenta en el PR con coste mensual estimado y delta.

### 4 — Interpreta el resultado

**Acción:** Lee el comentario: coste base, delta del PR y recursos que más pesan.
**Por qué:** Aprendes a usar la estimación como criterio de revisión, no como factura exacta.
**Resultado esperado:** Entiendes qué líneas del plan empujan el coste.

> [!NOTE]
> Infracost estima según precios públicos; la factura real depende de uso, descuentos y región
> (`us-east-2` en este curso).

## Comprueba tu entendimiento

**Comentario en PR**
Abre un PR con cambio de infraestructura.
→ Aparece un comentario de Infracost con coste estimado.

**Delta visible**
Compara el comentario antes y después de quitar un recurso del PR.
→ El delta baja o desaparece según el cambio.

## Reto

### 1 — Umbral de coste

¿Cómo harías que el workflow **falle** si el delta mensual supera 10 USD?

<details>
<summary>Ver solución</summary>

Tras `infracost breakdown`, usa `infracost diff` con `--sync-usage-file` o parsea el JSON y
comprueba `totalMonthlyCost` / `diffTotalMonthlyCost`. Alternativa: Infracost Cloud policies con
umbrales por repo. Para el lab, un paso `run` que lea el JSON con `jq` y haga `exit 1` si supera
10 es suficiente.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `Invalid API key` | Secreto mal copiado | Regenera la key en Infracost Cloud |
| Sin comentario en PR | Permisos del `GITHUB_TOKEN` | El workflow necesita `pull-requests: write` |
| Coste 0 en todo | Plan vacío o sin recursos de pago | Cambia un recurso con precio (EC2, RDS…) |
| `plan.json` inválido | Falta `terraform show -json` | Genera el JSON desde el plan binario |
