# DECISIONS — Heroes Lore: Zero Port

Registro de decisiones de alto impacto según Regla 17 del PLAN.md.

Cada entrada incluye: contexto, decisión, alternativas consideradas, evidencia de prueba y tareas afectadas.

---

## DEC-001 · Motor y versión

- **Fecha:** 2026-10-14
- **Tarea:** T0.1 / T0.4
- **Contexto:** El plan requiere Godot 4.x estable; la versión disponible localmente es 4.7.2.
- **Decisión:** Usar Godot 4.7.2 Standard (exe local en `C:\Proyecto HLZ\Godot_v4.7.2-stable_win64.exe\`). No actualizar en mitad de una fase sin pasar la batería de pruebas.
- **Alternativas:** Godot 4.4, 4.3. Descartadas por no estar disponibles localmente.
- **Evidencia:** `godot --version` → `4.7.2.stable.official.ed1daf0bf`
- **Tareas afectadas:** T0.4, T4.1, T4.10, exportación.

---

## DEC-002 · Renderizador inicial

- **Fecha:** 2026-10-14
- **Tarea:** T0.4
- **Contexto:** El plan indica partir de Godot Compatibility por su orientación a hardware amplio (portátiles y PCs de gama baja/media). La comparación con Mobile se hará en T4.10 con una escena representativa.
- **Decisión:** Inicializar el proyecto con renderizador **Compatibility**. Decisión definitiva pendiente de benchmark en T4.10.
- **Alternativas:** Mobile (más funciones), Forward+ (más avanzado pero mayor requisito de GPU).
- **Evidencia:** Pendiente de benchmark. Razón inicial: compatibilidad con hardware amplio.
- **Tareas afectadas:** T4.10, T4.12, T5.13.

---

## DEC-003 · Resolución y escalado

- **Fecha:** 2026-10-14
- **Tarea:** T0.4 / T4.1
- **Contexto:** Presentación en PC horizontal. Juego original vertical 360×640. El PLAN indica 1080p/60 FPS como objetivo en perfil bajo.
- **Decisión:** Resolución base de diseño 1920×1080, ventana inicial 1280×720, modo de escalado `canvas_items`, aspecto `expand`, filtro de textura Linear. Separar escala de contenido y escala de UI.
- **Alternativas:** 1280×720 como base (descartado: límita salida 4K), pixel-art con filtro Nearest (descartado: el arte es ilustrado, no pixel-art).
- **Evidencia:** Pendiente de validación visual en T4.7.
- **Tareas afectadas:** T4.1, T4.5, T4.6, T4.7, T4.12.

---

## DEC-004 · Perspectiva y dimensión del juego

- **Fecha:** 2026-10-14
- **Tarea:** T4.5–T4.7
- **Contexto:** PLAN.md §1 y §8 definen explícitamente 2D con vista cenital/top-down, inspirada en Bleaklight Falls en composición y lectura de terreno. No se construye escena 3D.
- **Decisión:** Juego 2D con vista cenital. La perspectiva exacta (cenital directa vs. ligeramente elevada por el arte) se decide en T4.6–T4.7 con prototipo y revisión humana.
- **Alternativas:** 3D con cámara ortogonal (descartado por plan).
- **Evidencia:** Pendiente de prototipo T4.6.
- **Tareas afectadas:** T4.5, T4.6, T4.7, toda la producción de arte.
