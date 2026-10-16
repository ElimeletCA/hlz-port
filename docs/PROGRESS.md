# PROGRESS — Heroes Lore: Zero Port

Documento canónico de seguimiento del estado real del proyecto.

Formato estándar de entrada:
```markdown
## TN.N · estado: hecho | en curso | bloqueado | pendiente
- Qué se hizo:
- Cómo se verificó (comando y resultado):
- Pendiente o dudas (→ OPEN_QUESTIONS.md):
```

---

## Resumen Ejecutivo de Estado (Auditoría Octubre 2026)

| Fase / Hito | Estado Real | Puerta Asociada | Evidencia Principal |
|---|---|---|---|
| **Fase 0: Entorno y Control** | **COMPLETA** (100%) | — | Herramientas operativas, Godot 4.7.2 headless/gráfico OK, `.gitignore` activo. |
| **Fase 1: Referencia Original** | **PARCIAL** (60%) | — | JAR en FreeJ2ME-Plus, 6 clases catalogadas, TICK_HZ=14 Hz, matriz inicial en `coverage.csv`. |
| **Fase 2: Ingeniería Inversa** | **COMPLETA** (100%) | **Gate A · APPROVED** | 144 clases decompiladas, 141 mapas JSON, 3,199 sprites PNG, parsers modulares verificados. |
| **Fase 3: Especificación Lógica** | **COMPLETA** (100%) | — | `docs/spec/*.md` (combate, movimiento, IA, progresión, eventos), suite de paridad 7/7 OK. |
| **Fase 4: Fundamentos Técnicos** | **COMPLETA** (100%) | **Gate B · APPROVED** | DisplayManager, GameClock, DataLoader, Cámara B aprobada, 134 sprites Lucian 100% paridad. |
| **Fase 5: Primer Recorrido E2E** | **EN CURSO** (Próximo Hito) | **Gate C (PENDING) / Gate D (PENDING)** | Componentes base listos en scripts; flujo integrado (T5.A a T5.H) pendiente de ensamblar. |
| **Fase 6: Producción Regional** | **BLOQUEADA** | **Gate E (BLOQUEADO)** | Estrictamente bloqueada hasta la aprobación explícita de Gate D por el usuario. |
| **Fase 7: Audio, HUD y QoL** | **PENDIENTE** | — | Programada tras arranque de Fase 6. |
| **Fase 8: QA y Regresión** | **PENDIENTE** | — | Programada al completar contenido. |
| **Fase 9: Versión 1.0** | **PENDIENTE** | **Gate F (PENDING)** | Empaquetado final y distribución limpia. |

---

## Registro Histórico de Tareas Completadas (Fases 0 a 4)

### Fase 0 — Entorno Reproducible
- **T0.1 · estado: hecho** — Instalación y verificación de Git 2.49, Python 3.11, JDK 17, FFmpeg, Godot 4.7.2, Vineflower 1.12.0, FluidSynth 2.6.1, FreeJ2ME-Plus y Krita 5.3.4.1. Verificado con `tools/paths.py`.
- **T0.2 · estado: hecho** — Estructura de directorios canónica, `.gitignore` estricto y documentos base (`PLAN.md`, `PROGRESS.md`, `OPEN_QUESTIONS.md`, `DECISIONS.md`).
- **T0.3 · estado: hecho** — Verificación criptográfica SHA-256 de `Heroes Lore Zero 360x640 Spanish.jar` (`F4F280AE14914867F5A2A5E4BFD30B139F8AB3F40E454A66D7433FCDB18A6331`).
- **T0.4 · estado: hecho** — Inicialización del proyecto Godot 4.7.2 con renderizador Compatibility y resolución 1920×1080. Verificado en headless y ventana.
- **T0.5 · estado: hecho** — Validación del pipeline de importación 2D y canal alfa (`godot/scenes/TestPipeline.tscn`).
- **T0.6 · estado: hecho** — Aprobación de la guía visual `art/STYLE.md` y plantilla `art/manifest.csv`.
- **T0.7 · estado: hecho** — Redacción de `DECISIONS.md`, `docs/spec/performance.md` y `docs/spec/content_scope.md`.
- **T0.8 · estado: hecho** — Registro de especificaciones de hardware del equipo de desarrollo (i7-11800H, RTX 3050 Ti Laptop / Intel UHD, 32 GB RAM).
- **T0.9 · estado: hecho** — Escena de benchmark sintética `godot/scenes/Benchmark2D.tscn` y script `benchmark.gd`.

### Fase 1 — Referencia del Juego Original
- **T1.1 · estado: hecho** — Ejecución del JAR en FreeJ2ME-Plus a 360×640 con soporte de gamepad. Script `tools/run_emulator.bat`.
- **T1.2 · estado: en curso** — Capturas de referencia de las 6 clases (Guerrero, Asesino, Caballero, Pistolero, Elemental, Gunblader) y sistemas de guardado en `docs/reference/`.
- **T1.3 · estado: hecho** — Catálogo de cobertura `docs/coverage.csv` enriquecido con jerarquía por regiones y estados de gate.
- **T1.4 · estado: hecho** — Frecuencia de lógica medida: `TICK_HZ = 14 Hz` (~71.4 ms/tick) confirmada en `rpg/e.java`.

### Fase 2 — Ingeniería Inversa y Extracción (Gate A · APPROVED)
- **T2.1 · estado: hecho** — Inventario exhaustivo del JAR: 1,112 archivos catalogados en `docs/inventory.csv`.
- **T2.2 · estado: hecho** — Decompilación de las 144 clases Java con Vineflower en `reverse/decompiled/`.
- **T2.3 · estado: hecho** — Desofuscación y mapeo de subsistemas en `reverse/mapping.txt`.
- **T2.4 · estado: hecho** — Especificaciones binarias en `docs/formats/`: `mpm.md`, `map_m.md`, `tdf.md`, `mmi.md`.
- **T2.5 · estado: hecho** — Parsers en Python en `tools/parsers/` para cada formato binario.
- **T2.6 · estado: hecho** — Extractor `tools/extract.py`: exportación a `out/` de 141 mapas JSON, 751 textos, 3,199 sprites PNG, 17 MIDI y 14 WAV.
- **T2.7 · estado: hecho** — Verificación con `tools/verify_fase2.py` (100% OK), 141 mapas renderizados en `out/renders/` y hojas de contacto generadas.
- **T2.8 · estado: hecho** — Catálogo de entidades y directrices de diseño en `art/refs/catalog.md`. Gate A ratificado.

### Fase 3 — Especificación Inversa de la Lógica
- **T3.1 · estado: hecho** — Arquitectura de reloj desacoplado a 14 Hz y máquina de estados en `docs/spec/engine.md`.
- **T3.2 · estado: hecho** — Modelo de movimiento continuo/discreto (3 px/tick = 42 px/s) y colisiones en `docs/spec/movement.md`.
- **T3.3 · estado: hecho** — Fórmulas matemáticas de combate, mitigación, críticos, evasión y vampirismo en `docs/spec/combat.md`.
- **T3.4 · estado: hecho** — Curva de experiencia exponencial (Lv 1-99), tablas de atributos y economía en `docs/spec/progression.md`.
- **T3.5 · estado: hecho** — FSM de IA de 6 estados y patrones de 11 jefes en `docs/spec/ai_enemies.md`.
- **T3.6 · estado: hecho** — Sistema de eventos, bitset de flags y persistencia en `docs/spec/events_quests.md`.
- **T3.7 · estado: hecho** — Suite de pruebas numéricas `tests/test_combat_parity.py` (7/7 tests aprobados).

### Fase 4 — Fundamentos Técnicos Integrados (Gate B · APPROVED)
- **T4.1 & T4.2 · estado: hecho** — Autoload `DisplayManager` con modos de pantalla y resoluciones de 720p a 4K.
- **T4.3 · estado: hecho** — Autoload `GameClock` a 14 Hz exactos con factor alfa de interpolación en física.
- **T4.4 · estado: hecho** — Autoload `DataLoader` para consumo de mapas y textos JSON.
- **T4.5 & T4.6 · estado: hecho** — Escena de encuadre y cámara `godot/scenes/CameraComparison.tscn`.
- **T4.7 · estado: hecho** — Aprobación humana de la Variante B (Cenital amplia, zoom 2.0x, offset -80 px) en `docs/spec/camera.md`.
- **T4.8 · estado: hecho** — Autoload `InputManager` para mapeo abstracto con mando y teclado.
- **T4.9 · estado: hecho** — Autoload `ProfileManager` con perfiles Bajo (59.2 FPS), Medio (58.6 FPS) y Alto (58.4 FPS).
- **T4.10 · estado: hecho** — Auditoría exhaustiva de Lucian Asesino (`hero/h1`): composición de 8 capas canónicas, resolución de desajustes de armas y recorte de lienzo (`Vector2(0, -100)`, 256×320 px a 4x).
- **T4.11 · estado: hecho** — Suite de validación en vivo en Godot (`godot/scripts/anim_review.gd`): 1,552 aserciones totales (1,548 PASS, 0 FAIL, 4 NOT TESTED justificadas). Corrección de direcciones en tests de combos, eliminación de tautologías, verificación de dimensiones/contenido y reporte fiable. Gate B ratificado.

---

## Estado Actual de la Fase 5: Hacia el Primer Recorrido Jugable (E2E)

> [!NOTE]
> Durante las pruebas anteriores se construyó una escena sandbox aislada (`VerticalSlice.tscn`) con elementos de prueba. Siguiendo la nueva filosofía oficial del proyecto (Principio B), la Fase 5 se reorganiza formalmente para construir el **recorrido jugable integrado de principio a fin** que el jugador experimentará desde el menú de inicio hasta el primer guardado.

### Desglose de Tareas de la Fase 5

#### T5.A · Menú Principal y Navegación
- **Estado:** `hecho`
- **Qué se hizo:** 
  - Creada la escena canónica `godot/scenes/MainMenu.tscn` y el script `godot/scripts/main_menu.gd`.
  - Configurado `run/main_scene="res://scenes/MainMenu.tscn"` en `project.godot` y actualizado `Main.tscn` para redirigir transparentemente al menú.
  - Opciones implementadas: "NUEVA PARTIDA", "CONTINUAR" (reactivo, desactivado sin partida guardada, habilitado con número de slot si existe partida), "OPCIONES" y "SALIR".
  - Panel modal de Opciones completo: Modo de Pantalla (Ventana, Pantalla Completa, Borderless), Resolución (1280x720 a 4K), V-Sync y Perfil Gráfico (Bajo, Medio, Alto) conectado con `DisplayManager` y `ProfileManager`.
  - Soporte completo para navegación por foco con Teclado (Enter, Espacio, Flechas, Escape) y Mando/Gamepad (D-pad, Stick, Botón A interactuar, Botón B cancelar/volver).
  - Integrada la textura original de título `ui_title.png` extraída del JAR.
  - Ampliado `SaveManager` con `has_any_save()` y `get_latest_save_slot()`.
- **Cómo se verificó:**
  - Batería de pruebas automatizadas `godot/scenes/TestMainMenu.tscn` (`scripts/test_main_menu.gd`): **21/21 aserciones aprobadas (100% PASS, 0 FAIL)** en modo headless y ventana.
  - Reporte de telemetría exportado en `godot/anim_captures/main_menu_test_results.json`.
  - Captura real en ventana generada en `godot/anim_captures/main_menu_preview.png`.
  - Cero regresiones en `test_combat_parity.py` (7/7 OK) y `AnimReview.tscn` (1,548 PASS, 0 FAIL, 4 NOT TESTED).
- **Pendiente o dudas:** La opción "Nueva Partida" muestra el punto de integración limpio hacia T5.B. La pantalla de selección de personaje se implementará en la siguiente tarea (T5.B).

#### T5.B · Selección de Personaje y Persistencia de Clase
- **Estado:** `pendiente` (Próxima tarea a ejecutar)
- **Qué se hará:** Crear `godot/scenes/CharacterSelect.tscn` y script `character_select.gd` permitiendo elegir entre las 4 clases iniciales (Asesino, Guerrero, Caballero, Pistolero), mostrando retrato, descripción y atributos.
- **Dependencias:** T5.A, T3.4.
- **Pruebas:** Confirmar que la clase elegida persiste en sesión y configura correctamente los sprites y stats del jugador.
- **Criterio:** Selección de clase asigna los atributos documentados en `docs/spec/progression.md`.

#### T5.C · Prólogo y Secuencia Narrativa Inicial
- **Estado:** `pendiente`
- **Qué se hará:** Crear `godot/scenes/Prologue.tscn` reproduciendo la introducción narrativa original y diálogos iniciales de `t/m/0.tdf` antes del control activo.
- **Dependencias:** T5.B, T2.6.
- **Pruebas:** Avance de texto con botón de interacción y transición automática al mapa 00 al terminar.
- **Criterio:** Recorrido del prólogo completable sin comandos de depuración.

#### T5.D · Inicio de la Aventura y Exploración de Aldea Silverleaf
- **Estado:** `pendiente`
- **Qué se hará:** Conectar al jugador en el mapa genuino 4x de Aldea Silverleaf (`m_00`), permitiendo exploración, colisión con el entorno y diálogo con al menos un NPC de la aldea.
- **Dependencias:** T5.C, T4.7, T4.10.
- **Pruebas:** Movimiento a 42 px/s, colisiones sólidas, cámara Variante B centrada con anticipación.
- **Criterio:** El jugador puede desplazarse por la aldea y dirigirse hacia la salida exterior.

#### T5.E · Primer Combate Completo y Recompensa
- **Estado:** `pendiente`
- **Qué se hará:** Integrar el encuentro hostil en el sendero exterior de Silverleaf con IA de combate, resolución de daño físico y combos de Lucian.
- **Dependencias:** T5.D, T3.3, T4.11.
- **Pruebas:** Recepción de daño, aplicación de varianza/críticos, derrota del enemigo y entrega de EXP.
- **Criterio:** Combate completo con animaciones, hitboxes y recompensas operativas.

#### T5.F · Persistencia y Continuación de Partida
- **Estado:** `pendiente`
- **Qué se hará:** Guardar partida tras el combate en `user://saves/save_slot_1.json`, salir al Menú Principal y verificar que la opción "Continuar" restaura la partida correctamente.
- **Dependencias:** T5.E, T5.A.
- **Pruebas:** Carga desde menú comprobando paridad de posición, HP, EXP e inventario.
- **Criterio:** Ciclo completo de guardado y carga persistente verificado.

#### T5.G · Prueba de Integración Extremo a Extremo (Gate C)
- **Estado:** `pendiente`
- **Qué se hará:** Automatizar y ejecutar la prueba continua completa: *Menú -> Selección -> Prólogo -> Silverleaf -> Combate -> Guardar -> Salir -> Continuar*.
- **Dependencias:** T5.A a T5.F.
- **Pruebas:** Ejecución en modo headless y gráfico registrando telemetría y capturas de cada hito.
- **Criterio:** 0 errores de script, Gate C pasa a `APPROVED`.

#### T5.H · Aprobación Formal de la Persona Responsable (Gate D)
- **Estado:** `pendiente` (Puerta bloqueante)
- **Qué se hará:** Entrega del recorrido jugable a la persona responsable del proyecto para su evaluación visual, táctil y técnica en `docs/gates/vertical_slice_approval.md`.
- **Dependencias:** T5.G.
- **Criterio:** Firma explícita de `APPROVED` otorgada por el usuario. Bloquea absolutamente la Fase 6.
