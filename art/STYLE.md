# STYLE GUIDE — Heroes Lore: Zero PC Port

**Documento Canónico de Dirección Artística y Pipeline Gráfico 2D**  
**Estado:** Actualizado y consolidado según DEC-004, DEC-006, DEC-007 y DEC-008 (Octubre 2026).

---

## 1. Identidad Visual y Filosofía Gráfica

El arte de *Heroes Lore: Zero para PC* se fundamenta en la **preservación y remasterización fiel a 4x pixel-perfect** de los recursos originales del juego de 2008 (JAR 360×640).

- **Fidelidad y Paridad:** Los personajes, criaturas, animaciones, mapas y tiles canónicos se obtienen mediante la extracción verificada y composición modular multicapa directamente del archivo JAR.
- **Referencia Atmosférica de Alto Nivel:** *Bleaklight Falls* se utiliza exclusivamente como inspiración para estudiar la lectura aérea del terreno, distribución de capas, viñeteado y profundidad visual. **Bajo ninguna circunstancia se copian sus sprites, personajes, mapas ni interfaz.**
- **Rol Estricto de la IA:** La generación libre mediante IA para sprites de juego y escenarios queda **expresamente descartada** (DEC-006). La IA y el retoque manual se reservan únicamente para:
  1. Retratos ilustrados de diálogo en alta resolución respetando las facciones de las hojas de expresiones oficiales coreanas (`docs/reference/lucian-official-expressions.png`).
  2. Elementos ornamentales de interfaz y fondos de menú.
  3. Limpieza manual y eliminación de artefactos en herramientas de pintura digital (Krita).

---

## 2. Perspectiva, Cámara y Encuadre (DEC-004 / T4.7 Aprobado)

- **Perspectiva:** 2D cenital con composición ligeramente elevada (~30º de inclinación en sprites).
- **Variante Aprobada (Variante B · Bleaklight Falls Inspiration):**
  - **Zoom de Cámara:** $2.0\times$ sobre el lienzo de renderizado base de $1920 \times 1080$.
  - **Offset Vertical de Cámara:** $(0, -80\text{ px})$ hacia arriba, proporcionando anticipación visual frontal tanto al explorar como al combatir.
  - **Adaptación de Mapas Verticales:** Los mapas originales conservan estrictamente sus proporciones de aspecto cuadradas sin estiramiento (`stretch = canvas_items`, `aspect = expand`).
  - **Bordes y Márgenes:** No se inventa terreno jugable fuera de los límites originales. Las áreas fuera de mapa se cubren con un lienzo ambiental con viñeteado difuso del color del bioma (ej. `#14171c` en exteriores, verde bosque oscuro o azul mazmorra).
- **Capas de Profundidad (Y-Sort):**
  1. Capa 1: Fondo / Tiles de suelo transitables (`z_index = 0`).
  2. Capa 2: Objetos decorativos inferiores y sombras de entidades (`z_index = 0`).
  3. Capa 3: Entidades dinámicas con ordenación Y-Sort activada (Héroe, NPCs, Enemigos, Cofres, Troncos de árboles, `y_sort_enabled = true`).
  4. Capa 4: Elementos de entorno superiores (Copas de árboles, techos de cabañas, arcadas, `z_index = 1`).
  5. Capa 5: Efectos visuales de combate (VFX tajos, proyectiles, partículas, `z_index = 2`).
  6. Capa 6: Interfaz de usuario (HUD, diálogos, menús, CanvasLayer independiente).

---

## 3. Escalas, Dimensiones y Punto de Apoyo (Pivote)

| Entidad / Recurso | Dimensión Base Original | Escala Canónica PC | Dimensión Final | Offset / Pivote en Godot |
|---|---|---|---|---|
| **Tile de Terreno** | $16 \times 16\text{ px}$ | $4\times$ entero | $64 \times 64\text{ px}$ | Centrado en casilla $(32, 32)$. |
| **Mapa Completo (ej. Silverleaf)** | $28 \times 40\text{ tiles}$ | $4\times$ entero | $1792 \times 2560\text{ px}$ | Origen en $(0, 0)$. |
| **Lucian Asesino (`hero/h1`)** | $64 \times 80\text{ px}$ | $4\times$ entero | $256 \times 320\text{ px}$ | **`offset = Vector2(0, -100)`**, pivote exacto en los pies. |
| **Enemigo Lobo (`en/01`)** | $20 \times 16\text{ px}$ | $4\times$ entero | $80 \times 64\text{ px}$ | Centrado en pies `offset = Vector2(0, -16)`. |
| **Props de Aldea (Cofres)** | $12 \times 12\text{ px}$ | $4\times$ entero | $48 \times 48\text{ px}$ | Pivote en base de colisión. |

---

## 4. Representación Canónica de Personajes y Composición de Capas (DEC-007)

La composición de sprites no utiliza hojas estáticas arbitrarias; se genera mediante el compositor modular multicapa J2ME (`tools/build_authentic_remaster.py`):

### Lucian Asesino (`hero/h1`): 8 Capas Canónicas
- **Capa 0:** Cabeza y cabello carmesí (`hero/0/00.mpm`), con ahoge superior, coleta baja con lazo azul y trenza lateral derecha.
- **Capa 1:** Chaleco de cuero ligero marrón/rojizo sin mangas (`hero/1/l00.mpm`, condición `dq.a() == false`).
- **Capa 2:** Pantalón morado, brazos descubiertos y muñequeras azul real (`hero/2/l00.mpm`).
- **Capa 3:** Botas de cuero de combate ágil (`hero/3/l00.mpm`).
- **Capa 4:** Tajos y efectos visuales dorados integrados (`hero/4/1.mpm`) para animaciones de ataque 6 y 7.
- **Capa 5:** Expresiones faciales y ojos verde esmeralda (`hero/eh.mpm`).
- **Capa 6:** Daga de acero principal (`hero/w/400.mpm`).
- **Capa 7:** Daga de acero secundaria en empuñadura doble ágil (`hero/w/400.mpm`).

---

## 5. Reglas de Animación y Sincronización Temporal (DEC-008)

- **Animación 0 — Reposo de Combate (8 fotogramas):** Reproducción en bucle a 6 FPS (respiración natural sin vibraciones parásitas, armas en guardia).
- **Animación 2 — Marcha de Combate (4 fotogramas base $\rightarrow$ 8 archivos a 10 FPS):**
  - `walk_<dir>_0` y `_4`: Zancada izquierda adelantada (Fotograma J2ME 0).
  - `walk_<dir>_1` y `_5`: Apoyo del pie izquierdo (Fotograma J2ME 1).
  - `walk_<dir>_2` y `_6`: Zancada derecha adelantada (Fotograma J2ME 2).
  - `walk_<dir>_3` y `_7`: Apoyo del pie derecho (Fotograma J2ME 3).
- **Animación 6 — Ataque Básico Combo 1 (5 fotogramas a 14 FPS):** Tajo doble giratorio con destellos dorados en F1 y F3.
- **Animación 7 — Remate Aéreo Combo 2 (3 fotogramas a 14 FPS):** Salto y estocada vertical hacia el suelo.
- **Animación 4 — Caída / Muerte (9 fotogramas):** Transición de colapso y reposo en suelo.

---

## 6. Criterios de Aceptación para Integración de Recursos

Ningún recurso gráfico se incorpora al proyecto Godot sin superar la siguiente lista de verificación:
1. **Canal Alfa Limpio:** Transparencia RGBA pura sin halos blancos ni bordes residuales.
2. **Dimensiones Enteras:** Múltiplos exactos de la cuadrícula original a escala 4x.
3. **Pivote y Alineación:** El punto de apoyo debe permanecer estrictamente en la base de contacto con el suelo entre fotogramas consecutivos.
4. **Continuidad Visual:** Cero deformaciones, estiramientos o saltos de proporciones entre reposo, marcha y combate.
5. **Auditoría de Procedencia:** Coincidencia verificada contra la matriz de datos original en `docs/coverage.csv` y `provenance_audit.json`.
