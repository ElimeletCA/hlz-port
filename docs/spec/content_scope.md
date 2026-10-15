# Alcance de contenido — Heroes Lore: Zero Port

Documento vivo. Refleja el inventario de contenido confirmado del juego original y su estado de implementación.

Fuente primaria: inspección del `.jar` (v4.4.45, español modificado). Las hipótesis se verifican en T2.1–T2.4.

### Archivo de referencia registrado (T0.3)
- **Archivo:** `input/Heroes Lore Zero 360x640 Spanish.jar`
- **Tamaño:** 1.367.966 bytes (1,30 MB)
- **SHA-256:** `F4F280AE14914867F5A2A5E4BFD30B139F8AB3F40E454A66D7433FCDB18A6331`
- **Estado de git:** Excluido por `.gitignore` (uso personal, no se versiona el binario)

---

## Matriz de contenido

> Estado posibles: `hipótesis` | `confirmado` | `descartado` | `pendiente T2.x`

| Categoría | Cantidad real | Fuente | Estado | Notas |
|-----------|---------------|--------|--------|-------|
| Clases Java | 144 | decompilación | confirmado | 144 clases decompiladas con Vineflower a `reverse/decompiled/` |
| Archivos `.mpm` | 460 | extracción out/ | confirmado | Reconstruidos en 3.199 sprites/frames PNG estándar |
| Mapas `.m` | 141 | extracción out/ | confirmado | 141 mapas exportados a JSON (tiles 16x16, capas y entidades) |
| Indicadores `mmi/` | 141 (70 B c/u) | extracción out/ | confirmado | Coordenadas de objetivo (X, Y) para 35 etapas de misión |
| Textos/misiones `.tdf` | 31 | extracción out/ | confirmado | 751 cadenas de texto en español extraídas en JSON |
| MIDI | 17 | extracción out/ | confirmado | 17 pistas de música en `out/audio/midi/` |
| WAV | 14 | extracción out/ | confirmado | 14 efectos de sonido en `out/audio/wav/` |
| PNG de UI | 39 | extracción out/ | confirmado | 39 texturas nativas en `out/ui/` |
| Fuente propia | 2 archivos | inspección .jar | confirmado | `ftd/table`, `dotFontSmall.dat` |
| Héroe / armas / equipo | 205 archivos | inspección `hero/` | confirmado | Sprites de Lucian y armas por clase |
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
