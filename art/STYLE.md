# STYLE GUIDE — Heroes Lore: Zero Port

**Estado: Aprobado formalmente por el usuario (🧑 2026-10-14)**

Este documento es la biblia visual 2D del proyecto. Define las directrices artísticas para la generación, retoque e integración de arte 2D cenital.

---

## Identidad visual

- El arte debe mantener la **identidad reconocible de Heroes Lore: Zero**: personajes, criaturas, atmósfera y narrativa propios del juego original.
- **Bleaklight Falls** es referencia de alto nivel para composición cenital, lectura del terreno, capas visuales y atmósfera expresiva. **No se copian** sus sprites, escenarios, personajes, UI ni assets.

---

## Perspectiva y composición

- **Vista cenital / top-down**, con posible elevación leve en la composición del arte para sugerir profundidad sin construir escena 3D.
- Decisión definitiva de perspectiva: **pendiente de T4.7** (revisión humana).
- Lectura clara del terreno, caminos y obstáculos desde la vista aérea.
- Capas de profundidad: suelo → objetos interactivos / enemigos / héroe → elementos de entorno (arbustos, muros) → follaje / tejados → efectos.

---

## Estilo

- Arte **2D ilustrado y estilizado**, con apariencia **pintada a mano**.
- Sombras pintadas directamente sobre los sprites, no generadas por motor 3D.
- Vegetación y elementos de entorno detallados pero legibles.
- Contornos: pendiente de definición (con/sin outline, grosor, color).
- Nivel de detalle: suficiente para pantalla 1080p a resolución de juego; no sobredimensionado para 4K nativo.

---

## Paleta (pendiente por bioma)

| Bioma / Zona | Paleta base | Estado |
|-------------|-------------|--------|
| — | pendiente de confirmación de zonas (Fase 2) | pendiente |

Reglas generales:
- Paleta coherente dentro de cada bioma.
- Contraste suficiente para distinguir héroe, enemigos, objetos, proyectiles y HUD en perfiles gráficos bajos.
- No degradar legibilidad al reducir calidad gráfica.

---

## Escala y tamaños base (pendiente)

| Elemento | Tamaño base sprite | Estado |
|----------|-------------------|--------|
| Héroe | pendiente T4.7 | — |
| Enemigo estándar | pendiente T4.7 | — |
| Tile de suelo | pendiente T4.5 | — |
| Tile de obstáculo | pendiente T4.5 | — |
| UI / HUD | pendiente T7.4 | — |

---

## Animación

- Sprites 2D por fotogramas como método principal.
- Comprobar continuidad visual entre frames, pivote/punto de apoyo, escala y temporización.
- Animaciones mínimas del héroe: reposo, movimiento (por dirección), ataque, habilidad, daño, muerte.
- Revisar dentro del juego a tamaño real, no solo ampliado en el editor.

---

## Tiles

- Bordes que conecten sin costuras.
- Variantes aprobadas para evitar repetición excesiva.
- Transiciones de terreno entre biomas.

---

## UI

- Basada en la identidad del diseño original.
- Escalable hasta 4K sin deformación.
- Navegación completa por foco (D-pad / stick).
- Fuentes legibles e iconos coherentes.

---

## Flujo obligatorio (Regla 12)

Referencia → generación IA → selección → retoque manual → limpieza → preparación frames/tiles → prueba en Godot → integración → aprobación.

Ningún recurso entra al juego solo porque lo haya generado la IA.

---

## Aprobación y vigencia

Documento revisado y aprobado por el usuario el 2026-10-14. Sirve como base para el vertical slice (Fase 5) y la producción controlada por lotes.

