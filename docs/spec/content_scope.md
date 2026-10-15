# Alcance de contenido — Heroes Lore: Zero Port

Documento vivo. Refleja el inventario de contenido confirmado del juego original y su estado de implementación.

Fuente primaria: inspección del `.jar` (v4.4.45, español modificado). Las hipótesis se verifican en T2.1–T2.4.

---

## Matriz de contenido

> Estado posibles: `hipótesis` | `confirmado` | `descartado` | `pendiente T2.x`

| Categoría | Cantidad hipótesis | Fuente | Estado | Notas |
|-----------|-------------------|--------|--------|-------|
| Clases Java | 144 | inspección .jar | confirmado | Ofuscadas; punto de entrada `rpg/RPGHeroEx` |
| Archivos `.mpm` | 460 | inspección .jar | hipótesis | Gráficos, animaciones y/o datos — verificar T2.4 |
| Mapas `.m` | ~140 | inspección .jar | hipótesis | En `m/m` y `m/m2` — verificar T2.4 |
| Atributos tile `.mmi` | 141 (70 B c/u) | inspección .jar | hipótesis | Colisión o atributos — verificar T2.4 |
| Textos/misiones `.tdf` | 31 | inspección .jar | hipótesis | Texto y misiones — verificar T2.4 |
| MIDI | 16 | inspección .jar | confirmado | En `snd/b` |
| WAV (8 kHz, 8b, mono) | 14 | inspección .jar | confirmado | En `snd/e` |
| PNG de UI | 39 | inspección .jar | confirmado | En raíz y `sks/` |
| Fuente propia | 2 archivos | inspección .jar | confirmado | `ftd/table`, `dotFontSmall.dat` |
| Héroe / armas / equipo | desconocido | hipótesis `hero/` | hipótesis | Verificar T2.3–T2.5 |
| Enemigos / stats | desconocido | hipótesis `en/` | hipótesis | Verificar T2.3–T2.5 |
| Objetos | desconocido | hipótesis `itm/` | hipótesis | Verificar T2.3–T2.5 |

---

## Contenido jugable (a verificar en Fase 1 y Fase 2)

| Categoría | Estado |
|-----------|--------|
| Mapas jugables (número exacto) | pendiente Fase 1 |
| NPC importantes | pendiente Fase 1 |
| Enemigos (tipos) | pendiente Fase 1 |
| Jefes | pendiente Fase 1 |
| Misiones / historia | pendiente Fase 1 |
| Objetos / equipo | pendiente Fase 2 |
| Habilidades | pendiente Fase 2 |
| Minijuegos | pendiente Fase 1 |
| Secretos / extras | pendiente Fase 1 |

---

## Notas de alcance

- La versión 1.0 no se declarará completa hasta cubrir el 100 % del contenido original confirmado.
- Las categorías marcadas como hipótesis se verifican en la Fase 2 leyendo el código decompilado.
- Las entradas dudosas se investigan y no se eliminan por conveniencia (Regla 16).
