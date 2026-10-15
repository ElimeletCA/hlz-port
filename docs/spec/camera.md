# Especificación de Cámara y Encuadre 2D (T4.5, T4.6, T4.7)

**Documento:** `docs/spec/camera.md`  
**Escena interactiva de prueba:** `res://scenes/CameraComparison.tscn`  
**Script:** `res://scripts/camera_comparison.gd`  
**Estado:** Prototipo funcional implementado (🧑 Pendiente de selección de variante en T4.7)  

---

## 1. Adaptación de Mapas Verticales a Pantallas Horizontales (1920×1080)

El juego original en J2ME operaba en resolución vertical orientada a teléfonos móviles ($360 \times 640$ píxeles). Los mapas miden típicamente entre $28 \times 40$ tiles ($448 \times 640$ px) y hasta $60 \times 80$ tiles.

### Reglas de Adaptación Aprobadas (T4.5):
1. **Sin Estiramiento:** Las proporciones de aspecto de los tiles ($16 \times 16\text{ px}$) y sprites se mantienen estrictamente al $100\%$ cuadradas (`aspect = expand`, `stretch = canvas_items`).
2. **Sin Terreno Jugable Inventado:** No se crean casillas transitables falsas fuera de los límites originales de cada mapa.
3. **Márgenes y Fondo Ambiental:**
   - Cuando la cámara llega a los extremos o en mapas más estrechos que el área visible, el espacio circundante se cubre con un lienzo ambiental viñeteado con el color base del bioma (`#14171c` en exteriores oscuros, verde musgo tenue en bosques, azul profundo en mazmorras).
   - En la producción de arte (Fase 6), estos bordes se enriquecen con capas de follaje no transitable, nubes bajas o sombras periféricas difusas.

---

## 2. Comparación de Variantes de Encuadre 2D (T4.6)

Se han implementado dos variantes totalmente funcionales y alternables en tiempo real con las teclas `1` y `2` en `res://scenes/CameraComparison.tscn`:

| Parámetro | Variante A: Cenital Directa (Top-Down Pure) | Variante B: Cenital Ligeramente Elevada (Recomendada · Bleaklight Falls) |
|---|---|---|
| **Perspectiva** | Cenital perpendicular estricta ($90^\circ$). | Cenital con composición ligeramente elevada ($\sim 30^\circ$ de inclinación visual en sprites). |
| **Nivel de Zoom** | $3.0\times$ (Encuadre cerrado centrado en casillas). | $2.35\times$ (Mayor amplitud de campo de visión horizontal). |
| **Offset de Cámara** | $(0, 0)$ estricto en el centro del héroe. | $(0, -32\text{ px})$ vertical hacia arriba, otorgando mayor anticipación visual frontal al caminar. |
| **Límites de Cámara** | Clampeo estricto a las coordenadas $[0, 0, W, H]$ del mapa. | Margen suave de $+32\text{ px}$ en bordes para permitir ver el entorno sin bordes cortados. |
| **Sensación Jugable** | Sensación clásica de RPG retro de cuadrícula. Área visible reducida. | Sensación de aventura inmersiva, mayor profundidad visual en capas y atmósfera pintada. |
| **Legibilidad de Caminos** | Alta en casillas inmediatas; baja en anticipación de enemigos lejanos. | Excelente: anticipa patrullas de enemigos y ramificaciones de caminos con claridad. |

---

## 3. Decisión y Aprobación Formal (🧑 T4.7 · Aprobado)

> [!IMPORTANT]
> **Decisión del Usuario (Checkpoint T4.7 - Aprobado):**
> Se adopta formal y exclusivamente la **Variante B (Cenital Amplia · Estilo Bleaklight Falls)**:
> 1. **Zoom:** $2.0\times$ (sobre lienzo base de 1920×1080 con escala 4x en tilesets).
> 2. **Offset:** $(0, -80\text{ px})$ vertical, otorgando anticipación frontal del camino y combate.
> 3. **Límites:** Márgenes suaves con degradado periférico en bioma.
> 4. **Estilo:** Cenital amplia con composición de profundidad atmosférica aprobada en `art/STYLE.md`.
>
> La Variante A queda descartada. Todas las escenas a partir de la Fase 5 utilizarán esta configuración de cámara.

---

## 4. Instrucciones para Ejecución y Evaluación por el Usuario

La escena puede ejecutarse directamente desde la terminal con:
```powershell
& "C:\Proyecto HLZ\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --path godot/ res://scenes/CameraComparison.tscn
```
- **Mover a Lucian:** Teclas de flecha, WASD o Stick analógico de mando.
- **Alternar Variante A:** Pulsar tecla `1` o botón "Variante A" en pantalla.
- **Alternar Variante B:** Pulsar tecla `2` o botón "Variante B" en pantalla.
