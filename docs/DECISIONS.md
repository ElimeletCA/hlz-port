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
- **Decisión:** Juego 2D con vista cenital. La perspectiva exacta adoptada es la Variante B (cenital con composición ligeramente elevada ~30º, zoom 2.0x, offset vertical -80 px en lienzo 1080p, bordes viñeteados por bioma sin inventar terreno transitable).
- **Alternativas:** 3D con cámara ortogonal (descartado por plan); Variante A cenital pura 90º (descartada en T4.7 por campo visual reducido).
- **Evidencia:** Aprobación explícita del usuario en T4.7 y documentación en `docs/spec/camera.md`.
- **Tareas afectadas:** T4.5, T4.6, T4.7, F5, F6.

---

## DEC-005 · Continuidad del motor y rechazo de migración a libGDX

- **Fecha:** 2026-10-15
- **Tarea:** Arquitectura general
- **Contexto:** Surgieron dudas sobre si migrar a un framework Java nativo (libGDX) para ejecutar el bytecode original.
- **Decisión:** Mantener estrictamente **Godot 4.7.2 con GDScript** como motor del juego para PC. No realizar migraciones tecnológicas. La paridad de lógica y fórmulas se garantiza mediante extracción de datos e ingeniería inversa documental, no ejecutando el runtime J2ME directamente.
- **Alternativas:** libGDX (descartado: requeriría reescribir todo el pipeline gráfico, UI, shaders, inputs y herramientas ya validadas).
- **Evidencia:** 1,548 aserciones aprobadas en suite de animación de Godot y paridad 7/7 en fórmulas de combate.
- **Tareas afectadas:** Todo el proyecto.

---

## DEC-006 · Dirección artística y reconstrucción fiel de recursos originales (4x Pixel-Perfect)

- **Fecha:** 2026-10-15
- **Tarea:** T5.10 / Pipeline de arte
- **Contexto:** Las generaciones con IA desconectadas de las capas originales causaban aberraciones visuales graves (hojas flotantes, desconexión de manos, falta de coherencia con el original). El usuario solicitó expresamente reutilizar y reescalar con máxima fidelidad los recursos y mapas originales.
- **Decisión:** La base gráfica del juego se fundamenta en la **extracción, composición modular por capas y reescalado entero 4x pixel-perfect** de los recursos originales del JAR (tilesets `t00`, `t26`, capas CIF de personajes). La IA y el retoque manual se reservan para tareas de asistencia, texturas de alta resolución, retratos e interfaces que mantengan estricta identidad visual con el original de 2008.
- **Alternativas:** Generación libre con IA desde cero (rechazada por el usuario por romper la identidad y fidelidad del juego).
- **Evidencia:** Mapa de Silverleaf 4x (`map_silverleaf.png`) y 134 sprites de Lucian con coincidencia 100% criptográfica contra el JAR original.
- **Tareas afectadas:** Pipeline de extracción, `tools/build_authentic_remaster.py`, `tools/verify_authentic_hero_assets.py`, F5, F6.

---

## DEC-007 · Representación canónica de Lucian Asesino (`hero/h1`)

- **Fecha:** 2026-10-15
- **Tarea:** T5.7 / Auditoría de Lucian
- **Contexto:** Se detectaron incongruencias en la clase de Lucian (se mezclaban dagas con la armadura de placas del Guerrero y espadón sobre el abdomen).
- **Decisión:** Establecer la representación canónica de Lucian como **Clase 1 (Asesino, `hero/h1`)**:
  - 8 capas compuestas: Capa 0 (cabeza y pelo rojo con coleta y ahoge), Capa 1 (`hero/1/l00`, chaleco ligero marrón/rojizo), Capa 2 (`hero/2/l00`, pantalón morado, brazos desnudos y muñequeras azul real), Capa 3 (`hero/3/l00`, botas de cuero), Capa 4 (`hero/4/1`, tajos VFX dorados en combos), Capa 5 (`hero/eh`, expresiones y ojos esmeralda), Capa 6 y 7 (`hero/w/400`, doble daga de acero).
  - Offset unificado en `Vector2(0, -100)` con lienzo de 256×320 px (64×80 base en 4x) y pivote en los pies.
- **Alternativas:** Forzar clase Guerrero con espadón (descartada al confirmarse el diseño canónico coreano de Asesino para el inicio).
- **Evidencia:** `provenance_audit.json` con 134/134 sprites validados al 100% contra el JAR y `KNOWN_GRAPHICS_ISSUES.md`.
- **Tareas afectadas:** `godot/scripts/player.gd`, `tools/build_authentic_remaster.py`, `godot/scripts/anim_review.gd`.

---

## DEC-008 · Mapeo del ciclo de marcha (4 fotogramas base J2ME a 8 archivos de animación)

- **Fecha:** 2026-10-16
- **Tarea:** T5.7 / Validación de marcha
- **Contexto:** En el motor J2ME (`dg.java`, Animación 2 de combate), la marcha consta de 4 fotogramas gráficos base. En el motor Godot a 10 FPS, se requerían 8 pasos para fluidez de ciclo.
- **Decisión:** Mapear los 8 archivos de marcha (`hero_lucian_walk_<dir>_0.png` a `7.png`) basándose en los 4 fotogramas originales repetidos dos veces consecutivas mediante `f_idx = i % 4`:
  - `walk_0` y `_4`: Fotograma 0 (zancada izquierda adelante).
  - `walk_1` y `_5`: Fotograma 1 (apoyo izquierdo).
  - `walk_2` y `_6`: Fotograma 2 (zancada derecha adelante).
  - `walk_3` y `_7`: Fotograma 3 (apoyo derecho).
- **Alternativas:** Interpolar fotogramas intermedios artificialmente (descartado para evitar deformaciones o borrosidad).
- **Evidencia:** Monotonicidad estricta y 0 caídas en reposo verificadas en `anim_review.gd` a 60 Hz física.
- **Tareas afectadas:** `godot/scripts/player.gd`, `tools/verify_authentic_hero_assets.py`.

---

## DEC-009 · Metodología de validación dual y reporte honesto de la suite

- **Fecha:** 2026-10-16
- **Tarea:** Suite de animación en `anim_review.gd`
- **Contexto:** Existían aserciones tautológicas (`true == true`) y confusión entre consistencia de archivos generados y verificación contra el JAR.
- **Decisión:** Separar estrictamente la validación en dos niveles:
  1. **Consistencia de archivos generados (Modo 1):** Valida existencia, dimensiones (`256x320`), offset, escala y contenido de píxeles no vacío (`get_used_rect().has_area() == true`).
  2. **Ejecución real autónoma (Modo 2):** Valida estados, direcciones, monotonicidad y transiciones sin forzar texturas ni timers.
  3. **Auditoría criptográfica:** Valida dinámicamente el informe de paridad píxel a píxel contra el JAR.
  4. **Dictamen honesto:** El estado final nunca declara éxito incondicional. Si hay fallos reporta `CON_DEFECTOS`; si hay propiedades no comprobadas por hardware móvil reporta `APROBADO_CON_EXCLUSIONES` separando `pass_count` y `not_tested_count`.
- **Alternativas:** Aserciones estáticas hardcodeadas (eliminadas por tautológicas).
- **Evidencia:** 1,552 aserciones registradas en `anim_validation_results.json` (1,548 PASS, 0 FAIL, 4 NOT TESTED).
- **Tareas afectadas:** `godot/scripts/anim_review.gd`, `KNOWN_GRAPHICS_ISSUES.md`.

---

## DEC-010 · Metodología de desarrollo incremental guiado por la historia (Vertical Slice real a Producción Regional)

- **Fecha:** 2026-10-16
- **Tarea:** Reorganización técnica y arquitectónica del proyecto
- **Contexto:** El proyecto construyó subsistemas de prueba aislados (sandbox `VerticalSlice.tscn`) sin haber integrado el flujo real del juego desde su arranque.
- **Decisión:** Adoptar una metodología estrictamente guiada por la historia original:
  1. No construir sistemas aislados innecesarios.
  2. Construir en Fase 5 un **Primer Recorrido Jugable Completo de principio a fin** (Menú Principal -> Selección de Personaje -> Prólogo narrativo -> Primer Mapa -> Interacción -> Primer Combate -> Guardado -> Carga) sin comandos de depuración ni teletransportes.
  3. Establecer una **Puerta de Aprobación Humana (Gate D)** que bloquea absolutamente la producción masiva de la Fase 6 hasta que este primer recorrido sea probado y aprobado explícitamente por el usuario.
  4. Tras la aprobación, producir el resto del juego en Fase 6 **cronológicamente por regiones de la historia original** (Silverleaf -> Humming -> Desierto -> Mazmorras -> Final), validando cada región de forma autónoma antes de avanzar a la siguiente.
- **Alternativas:** Producción masiva en paralelo de mapas y enemigos sin juego integrado (descartada por alto riesgo de retrabajo y pérdida de foco).
- **Evidencia:** Solicitud explícita de arquitectura del usuario y consolidación en `docs/PLAN.md`.
- **Tareas afectadas:** Todo el plan de desarrollo (Fase 0 a Fase 9).
