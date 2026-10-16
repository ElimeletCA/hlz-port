# Heroes Lore: Zero — PC Port (Fan-Made)

Proyecto de ingeniería inversa y reconstrucción integral del videojuego clásico para móviles **Heroes Lore: Zero** (J2ME, 2008), adaptado para PC moderna utilizando **Godot Engine 4.7.2**, **GDScript** y un pipeline de gráficos 2D remasterizados a 4x pixel-perfect.

---

## 1. Visión y Filosofía de Desarrollo

El objetivo del proyecto es recrear la experiencia completa del juego original con fidelidad matemática, narrativa y visual, incorporando mejoras modernas de calidad de vida sin alterar las reglas del juego.

El desarrollo se rige por cinco principios fundamentales:

1. **Base técnica suficiente sin sistemas aislados:** Se estabilizan primero los fundamentos mínimos necesarios para un recorrido real, ampliando la tecnología conforme lo requiera la historia.
2. **Primer recorrido jugable completo (Vertical Slice - Fase 5):** Antes de la producción masiva, se construye un recorrido integrado desde el Menú Principal hasta el primer combate y guardado de partida.
3. **Producción guiada por la historia (Fase 6):** Tras la aprobación formal del primer recorrido, el contenido se produce cronológicamente, región por región.
4. **Fidelidad al original:** Fórmulas de combate, textos, diálogos, mapas y stats se extraen directamente del JAR original (`Heroes Lore Zero 360x640 Spanish.jar`).
5. **Cambios atómicos y verificables:** Cada avance cuenta con un identificador único, criterios de aceptación objetivos, pruebas reproducibles y un commit atómico inmediato.

---

## 2. Pila Tecnológica

- **Motor Principal:** Godot Engine 4.7.2 Standard (64-bit) con renderizador **Compatibility** (OpenGL 3.3 / ANGLE).
- **Lenguaje del Juego:** GDScript.
- **Herramientas de Extracción e Ingeniería Inversa:** Python 3.11 (Pillow, parsers binarios modulares).
- **Herramientas de Análisis:** Vineflower 1.12.0 (decompilador Java), FreeJ2ME-Plus (emulador MIDP/J2ME), FluidSynth 2.6.1 (renderizado de audio MIDI), Krita 5.3 (retoque visual 2D).
- **Plataforma Objetivo:** Windows 10 / 11 de 64 bits.

---

## 3. Estructura del Repositorio

```text
hlz-port/
├── docs/                     # Documentación oficial y especificaciones
│   ├── PLAN.md               # Plan maestro canónico (Fases 0 a 9)
│   ├── PROGRESS.md           # Seguimiento en tiempo real de tareas
│   ├── DECISIONS.md          # Registro de decisiones de arquitectura (DEC-001 a DEC-010)
│   ├── OPEN_QUESTIONS.md     # Incertidumbres técnicas y preguntas abiertas
│   ├── coverage.csv          # Matriz de cobertura regional del 100% del juego
│   ├── formats/              # Especificación de formatos binarios (.mpm, .m, .tdf, mmi)
│   ├── spec/                 # Especificaciones de combate, movimiento, IA, progresión y cámara
│   ├── gates/                # Puertas de aprobación formal (Gate A a Gate F)
│   └── diagnostics/          # Informes técnicos de auditoría de gráficos y animaciones
├── godot/                    # Proyecto de juego en Godot 4
│   ├── scenes/               # Escenas (.tscn): Player, AnimReview, World, etc.
│   ├── scripts/              # Scripts (.gd): Controladores, autoloads y suites de prueba
│   └── art_samples/          # Texturas y sprites remasterizados a 4x pixel-perfect
├── tools/                    # Extractores, parsers y scripts de verificación en Python
│   ├── parsers/              # Módulos para decodificar .mpm, .m, .tdf y mmi
│   ├── extract.py            # Extractor maestro del archivo JAR original
│   ├── build_authentic_remaster.py # Generador de composiciones canónicas por capas
│   └── verify_authentic_hero_assets.py # Auditoría criptográfica píxel a píxel
├── tests/                    # Pruebas automatizadas de lógica y paridad numérica
├── input/                    # Archivo JAR original de referencia (local, en .gitignore)
└── out/                      # Datos binarios extraídos a JSON/PNG/Audio (local, en .gitignore)
```

---

## 4. Puertas de Aprobación Formales (Gates)

| Gate | Nombre | Documento | Estado | Descripción |
|---|---|---|---|---|
| **Gate A** | Recursos Decodificados | `docs/gates/gate_a_resources.md` | **APPROVED** | 100% del JAR extraído y verificado sin errores. |
| **Gate B** | Fundamentos Gráficos | `docs/gates/gate_b_graphics_anims.md` | **APPROVED** | Sprites de Lucian auditados con paridad 100% y suite en vivo aprobada. |
| **Gate C** | Primer Recorrido E2E | `docs/gates/gate_c_first_walkthrough.md` | **PENDING** | Integración técnica del flujo Menú -> Prólogo -> Mapa -> Combate -> Guardar. |
| **Gate D** | Aprobación del Vertical Slice | `docs/gates/vertical_slice_approval.md` | **PENDING · BLOQUEANTE** | Evaluación jugable por la persona responsable. Bloquea Fase 6. |
| **Gate E** | Integración Regional | `docs/gates/gate_e_region_template.md` | **BLOQUEADO** | Control de calidad aplicado a cada una de las 5 regiones de la Fase 6. |
| **Gate F** | Versión Final 1.0 | `docs/gates/gate_f_release_1_0.md` | **PENDING** | Cobertura total, empaquetado y prueba integral limpia. |

---

## 5. Instrucciones de Ejecución y Pruebas

### Ejecutar Suite de Validación de Animaciones (Godot 4)
Para verificar la suite completa de 1,552 aserciones sobre el controlador de Lucian:
```powershell
& "C:\Proyecto HLZ\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path godot/ res://scenes/AnimReview.tscn
```

### Ejecutar Pruebas de Paridad de Combate (Python)
Para verificar las fórmulas matemáticas de daño, críticos, evasión y experiencia:
```powershell
python tests/test_combat_parity.py
```

### Ejecutar Auditoría Criptográfica de Recursos
Para verificar que los 134 sprites de Lucian coinciden píxel a píxel contra el bytecode J2ME:
```powershell
python tools/verify_authentic_hero_assets.py
```

---

## 6. Flujo de Trabajo para Desarrolladores y Agentes de IA

1. Consultar siempre `docs/PLAN.md` y `docs/PROGRESS.md` antes de iniciar cualquier tarea.
2. Trabajar en **una sola tarea atómica a la vez**, ejecutando sus pruebas antes de darla por concluida.
3. Comitear cada cambio de manera inmediata con mensajes descriptivos bajo formato convencional (`feat:`, `fix:`, `docs:`, `test:`).
4. No saltar a la producción masiva de la Fase 6 mientras `docs/gates/vertical_slice_approval.md` permanezca en `PENDING`.
5. Detenerse y consultar a la persona responsable ante cualquier duda de diseño o discrepancia narrativa.
