# Puerta de aprobación — Vertical Slice

Archivo de aprobación formal antes de la producción masiva (Fase 6).

**Estado actual: `pendiente`**

Estados válidos: `pendiente` | `rechazada` | `aprobada con condiciones` | `aprobada`

---

## Requisitos para cambiar de estado

1. El usuario ha jugado o revisado una demostración reproducible de la escena integrada (T5.10).
2. La escena incluye: héroe retocado manualmente, al menos un enemigo animado, mapa con tiles definitivos, elemento superpuesto, objeto interactivo, combate, colisiones, efectos y HUD.
3. Se han validado: perspectiva, estilo 2D ilustrado, animaciones, arquitectura, combate y rendimiento en la misma escena.
4. Los resultados visuales y técnicos están documentados.
5. La aprobación es explícita del usuario (no se infiere).

---

## Checklist (completar en T5.14)

- [ ] T5.10 · Escena integrada preparada
- [ ] T5.11 · Validación visual y de arte
- [ ] T5.12 · Validación jugable
- [ ] T5.13 · Validación de rendimiento
- [ ] Decisión del usuario registrada

---

## Historial de revisiones

| Fecha | Estado | Notas |
|-------|--------|-------|
| — | pendiente | Fase 0 en curso |

---

> [!CAUTION]
> La producción masiva de la Fase 6 solo se desbloquea con estado `aprobada`. La ausencia de respuesta, las pruebas aisladas o una escena con placeholders en componentes esenciales NO cuentan como aprobación.
