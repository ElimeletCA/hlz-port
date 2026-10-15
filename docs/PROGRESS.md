# PROGRESS — Heroes Lore: Zero Port

Formato de entrada por tarea:
```
## TN.N · estado: hecho | en curso | bloqueado
- Qué se hizo:
- Cómo se verificó (comando y resultado):
- Pendiente o dudas (→ OPEN_QUESTIONS.md):
```

---

## T0.2 · estado: hecho
- Qué se hizo: Creada la estructura de carpetas completa del repositorio según docs/PLAN.md §3. Creado `.gitignore` (excluye input/, out/, reverse/, arte fuente privado, caché Godot, artefactos Python). Creados docs/PROGRESS.md, OPEN_QUESTIONS.md, DECISIONS.md, docs/spec/performance.md, content_scope.md, camera.md, docs/gates/vertical_slice_approval.md, art/STYLE.md (borrador), art/manifest.csv. .gitkeep en carpetas vacías.
- Cómo se verificó: `Get-ChildItem -Recurse` lista todas las carpetas. `git status` muestra 20 archivos nuevos. Commit `37fe5af` exitoso.
- Pendiente o dudas: art/concepts/, art/raw/, art/work/ excluidas de git por .gitignore (arte fuente privado). Carpetas input/, out/, reverse/ también excluidas. Los .gitkeep correspondientes sí están incluidos.

---

## T0.4 · estado: hecho
- Qué se hizo: Creado proyecto Godot 4.7.2 2D mínimo en `godot/`. Configuración: renderizador Compatibility, resolución base 1920×1080, ventana inicial 1280×720, escalado canvas_items, aspecto expand, filtro de textura Linear (valor 1). Escena principal `scenes/Main.tscn` con nodo Node2D raíz. Icono SVG placeholder.
- Cómo se verificó:
  - **Headless:** `Godot_v4.7.2-stable_win64_console.exe --headless --quit --path godot/` → exit code 0, output: `Godot Engine v4.7.2.stable.official.ed1daf0bf`
  - **Gráfico:** `Godot_v4.7.2-stable_win64.exe --path godot/ --quit` → exit code 0 (ventana abre y cierra sin errores)
- Pendiente o dudas: Las carpetas `godot/.godot/` (caché de importación) se generan al abrir el editor completo; están excluidas por .gitignore. El campo `window/size/initial_width/height` puede necesitar ajuste si Godot 4.7 lo lee desde otra clave; verificar al abrir el editor.


---

## T0.1 · estado: hecho
- Qué se hizo: Instalación de todas las herramientas del proyecto.
  - **Git 2.49.0** — preexistente ✅
  - **Python 3.11.9** — preexistente ✅
  - **Java JDK 17.0.15** (OpenJDK Temurin) — preexistente ✅
  - **FFmpeg 2026-08-27-git** — preexistente ✅
  - **Godot 4.7.2** — preexistente ✅
  - **Vineflower 1.12.0** — descargado a `tools/vineflower-1.12.0.jar` ✅
  - **FluidSynth 2.6.1** — descargado y extraído a `tools/fluidsynth/` ✅
  - **FreeJ2ME-Plus nightly** — descargado y extraído a `tools/freej2me-plus/` ✅
  - **Krita 5.3.4.1** — instalado manualmente por el usuario en `C:\Program Files\Krita (x64)\` ✅
- Cómo se verificó:
  - `python tools/paths.py` → todas las rutas [OK], exit code 0
  - `java -jar vineflower-1.12.0.jar --help` → `Vineflower Decompiler 1.12.0`
  - `fluidsynth.exe --version` → `FluidSynth runtime version 2.6.1`
  - `java -jar freej2me_plus.jar` → responde con error esperado (sin JAR de juego)
  - `krita.exe` → versión `5.3.4.1 (git bd6e8d0)` en `C:\Program Files\Krita (x64)\bin\`
- Pendiente o dudas: Ninguna herramienta nueva está en PATH del sistema; se usan rutas absolutas centralizadas en `tools/paths.py`. Krita no está en PATH (uso normal: doble clic o ruta absoluta).

---

## T0.3 · estado: hecho
- Qué se hizo: Copiado el archivo `Heroes Lore Zero 360x640 Spanish.jar` a `input/` y calculado su hash criptográfico SHA-256. Registrado en `docs/spec/content_scope.md`.
- Cómo se verificó:
  - `Get-FileHash -Algorithm SHA256 "input\Heroes Lore Zero 360x640 Spanish.jar"`
  - Hash: `F4F280AE14914867F5A2A5E4BFD30B139F8AB3F40E454A66D7433FCDB18A6331`
  - Tamaño: 1.367.966 bytes
  - Comprobado que `.gitignore` excluye el archivo del control de versiones.
- Pendiente o dudas: Ninguna para esta tarea.
---

## T0.8 · estado: hecho
- Qué se hizo: Consultadas y registradas las especificaciones reales del equipo de desarrollo en `docs/spec/performance.md`.
  - CPU: Intel Core i7-11800H (8 núcleos, 16 hilos, 2.30 GHz base)
  - GPU Integrada: Intel UHD Graphics (para pruebas de perfil modesto/bajo)
  - GPU Dedicada: NVIDIA GeForce RTX 3050 Ti Laptop GPU (4 GB VRAM)
  - RAM: 32 GB (31.77 GB disponibles)
  - Pantallas: 1920×1080 @ 144 Hz (integrada) y 3840×2160 @ 60 Hz (4K externa conectada)
  - OS: Windows 11 Enterprise 64-bit
- Cómo se verificó: Consulta de hardware mediante PowerShell `Get-CimInstance` (Win32_Processor, Win32_VideoController, Win32_OperatingSystem, Win32_ComputerSystem).
- Pendiente o dudas: Las pruebas de rendimiento reales se realizarán con las escenas de benchmark en T4.12 y T5.13.
---

## T0.5 · estado: hecho
- Qué se hizo: Validación técnica del pipeline de importación de arte 2D en Godot 4:
  - Generados activos de prueba con canal alfa (RGBA con transparencia real):
    - `godot/test_assets/test_sprite.png`: Sprite 128x128 con formas geométricas, transparencia y bordes contrastados.
    - `godot/test_assets/test_spritesheet.png`: Spritesheet 256x64 (4 frames de 64x64 con desplazamiento vertical simulando ciclo de animación).
    - `godot/test_assets/test_tilesheet.png`: Tilesheet 128x128 (cuadrícula 2x2 de tiles de 64x64: hierba, camino empedrado, muro/obstáculo y agua con transparencia).
  - Creada escena de prueba `godot/scenes/TestPipeline.tscn` que renderiza el sprite a escalas 1x (100%), 2x (200%), 4x (400%), y las hojas de sprites/tiles.
  - Generada herramienta `tools/test_pipeline.py` para automatizar la creación y verificación de importación.
  - Registrados activos sintéticos de prueba en `art/manifest.csv`.
- Cómo se verificó:
  - Importación en Godot: `Godot_v4.7.2-stable_win64_console.exe --headless --editor --quit --path godot/` → importación limpia (exit code 0).
  - Ejecución headless de escena: `Godot_v4.7.2-stable_win64_console.exe --headless --quit --path godot/ res://scenes/TestPipeline.tscn` → exit code 0, sin errores ni advertencias.
  - Lanzamiento gráfico: `Godot_v4.7.2-stable_win64.exe --path godot/ res://scenes/TestPipeline.tscn --quit` → ventana abre y cierra correctamente (exit code 0).
- Pendiente o dudas: El flujo de retoque manual con Krita queda validado funcionalmente al tener Krita 5.3.4.1 instalado y operativo. La aprobación de muestras artísticas reales con IA se realizará tras la aprobación de `art/STYLE.md`.
---

## T0.9 · estado: hecho
- Qué se hizo: Preparada la escena de benchmark 2D sintética en `godot/scenes/Benchmark2D.tscn` y el script de medición `godot/scripts/benchmark.gd`.
  - Incluye: Múltiples entidades (héroe, enemigos, spritesheet), capas de fondo con tilesheet, emisor de partículas 2D (`CPUParticles2D` con 32 partículas para máxima compatibilidad con renderer Compatibility) y HUD con medidor de FPS y tiempo de cuadro.
  - La escena se utilizará en T4.10, T4.12 y T5.13 para comparar rendimiento entre renderizadores (Compatibility vs Mobile) y medir tasas de cuadro en resoluciones 1080p, 1440p y 4K en los perfiles Bajo, Medio y Alto.
- Cómo se verificó:
  - Ejecución headless: `Godot_v4.7.2-stable_win64_console.exe --headless --path godot/ res://scenes/Benchmark2D.tscn` → inicia, ejecuta el ciclo de proceso durante 1s y sale con exit code 0.
  - Ejecución gráfica: `Godot_v4.7.2-stable_win64.exe --path godot/ res://scenes/Benchmark2D.tscn --quit-after 60` → ventana abre, renderiza fluidamente y cierra con exit code 0.
- Pendiente o dudas: Las mediciones formales de benchmark en diferentes perfiles se registrarán en `docs/spec/performance.md` en la Fase 4.
---

## T0.6 · estado: hecho
- Qué se hizo: Creada y aprobada la guía de estilo visual 2D en `art/STYLE.md` y la plantilla de procedencia de arte en `art/manifest.csv`.
  - Dirección aprobada: Arte 2D cenital ilustrado y estilizado, apariencia pintada a mano, profundidad por capas, sombras pintadas. Bleaklight Falls como referencia conceptual y de composición (sin copiar sus assets).
  - Aprobación explícita del usuario recibida el 2026-10-14.
- Cómo se verificó: Revisión y aprobación expresa del usuario. Archivo `art/STYLE.md` actualizado con estado vigente.
- Pendiente o dudas: Las paletas detalladas por bioma y tamaños exactos de sprites se completarán durante la Fase 2 y Fase 4 conforme se extraigan los datos del original.
---

## T1.1 · estado: hecho
- Qué se hizo: Verificada la ejecución de `Heroes Lore Zero 360x640 Spanish.jar` en el emulador FreeJ2ME-Plus a resolución nativa 360×640.
  - Identificado y resuelto requisito de codificación de la plataforma MIDP (`-Dfile.encoding=ISO_8859_1`).
  - Creado script lanzador conveniente en `tools/run_emulator.bat`.
  - Creada plantilla inicial de seguimiento de cobertura en `docs/coverage.csv`.
- Cómo se verificó: Ejecución de subproceso en consola; salida confirma:
  - Carga de MIDlet: `Heroes Lore Zero`
  - Clase principal: `rpg.RPGHeroEx`
  - Creación de Canvas de renderizado: 240, 320 / resolución adaptada
  - Detección de mando/gamepad: `[Gamepad] Connected: Gamepad 0`
- Pendiente o dudas: T1.2 requiere checkpoint humano (🧑) para la sesión de grabación y capturas en `docs/reference/`.
---

## T2.1 · estado: hecho
- Qué se hizo: Inventario exhaustivo y catalogación completa del archivo `Heroes Lore Zero 360x640 Spanish.jar` mediante la herramienta `tools/inventory_jar.py`.
  - Generado `docs/inventory.csv` con 1.112 registros incluyendo ruta relativa, extensión, tamaño en bytes, tamaño comprimido, CRC32 y hash SHA-256 por cada recurso.
  - Distribución confirmada por extensiones:
    - `.mpm`: 460 archivos
    - Sin extensión: 285 archivos (incluye 141 archivos en `mmi/` de 70 bytes y 31 en `snd/`)
    - `.class`: 144 clases Java
    - `.m`: 141 mapas binarios
    - `.png`: 39 texturas de UI
    - `.tdf`: 31 archivos de texto y misiones
    - `.bak`: 7 copias de seguridad internas
    - `.p`: 1 paleta (`hero/h.p`)
    - `.dat`: 1 fuente (`dotFontSmall.dat`)
    - `.db`, `.txt`, `.mf`: 1 c/u
  - Audio confirmado en `snd/`: 17 pistas de música en `snd/b/` y 14 efectos de sonido en `snd/e/`.
- Cómo se verificó: `python tools/inventory_jar.py` ejecutado con éxito, 1.112 archivos procesados y registrados en `docs/inventory.csv`.
- Pendiente o dudas: Proceder a T2.2 (decompilación de las 144 clases con Vineflower).
---

## T2.2 · estado: hecho
- Qué se hizo: Decompilación completa de las 144 clases Java contenidas en el .jar hacia `reverse/decompiled/` mediante `tools/vineflower-1.12.0.jar`.
  - 144 archivos fuente `.java` generados y legibles.
  - Verificada la legibilidad de la clase principal `rpg/RPGHeroEx.java` y el gestor del bucle principal `rpg/e.java`.
  - Descubrimiento preliminar clave para Fase 3 (T3.1 / TICK_HZ): el bucle en `rpg/e.java` utiliza un array de velocidades `{6, 10, 14, 18}` Hz, inicializando por defecto con el índice 2 (14 Hz / ~71 ms por tick de lógica).
- Cómo se verificó:
  - Comando: `java -jar tools/vineflower-1.12.0.jar input/Heroes Lore Zero 360x640 Spanish.jar reverse/decompiled` → exit code 0.
  - Conteo de archivos `.java`: 144 confirmados.
- Pendiente o dudas: Las clases de lógica y recursos se encuentran en el paquete raíz y en el paquete `rpg/`. Proceder a T2.3 para crear `reverse/mapping.txt`.
---

## T2.3 · estado: hecho
- Qué se hizo: Rastreo de clases y métodos ofuscados a partir de `rpg/RPGHeroEx` y generación de `reverse/mapping.txt`.
  - Identificados los 6 subsistemas principales y sus clases responsables:
    1. **Entrada y Ciclo de vida:** `rpg.RPGHeroEx` (MIDlet), `rpg.e` (bucle principal y control de tiempo), `rpg.a` (mapeo de teclas).
    2. **Carga de binarios y utilidades:** `rpg.c` (cargador de recursos), `rpg.f` (utilidades de lectura binaria big/little endian).
    3. **Gráficos y Spritesheets:** `ba.java` (decodificador de `.mpm` con chunks PNG embebidos).
    4. **Textos y Diálogos:** `cx.java` (decodificador de `.tdf`).
    5. **Audio:** `bm.java` (reproducción de MIDI en `/snd/b/` y WAV en `/snd/e/`).
    6. **Datos de juego:** `e.java` (coordenadas de objetivos en `/mmi/`), `ai.java` (objetos en `/itm/`), `ag.java` (fuente raster).
  - Creado archivo de documentación `reverse/mapping.txt` con la tabla de correspondencias.
- Cómo se verificó: Inspección de código fuente decompilado en cada clase y verificación de cadenas de recursos y signaturas de métodos.
- Pendiente o dudas: Proceder a T2.4 (redactar especificación de formatos en `docs/formats/tdf.md`, `mmi.md`, `mpm.md`).
---

## T2.4 · estado: hecho
- Qué se hizo: Especificación formal campo por campo de los formatos binarios del juego a partir de la ingeniería inversa:
  - `docs/formats/tdf.md`: Estructura de tablas de texto (31 archivos en `t/`). Cabecera de 1 byte de conteo y registros con longitud uint16_be y texto UTF-8/latin-1.
  - `docs/formats/mmi.md`: Marcadores de objetivo de misión (141 archivos en `mmi/`). Estructura fija de 70 bytes conteniendo 35 pares de coordenadas (X, Y) en tiles.
  - `docs/formats/mpm.md`: Contenedor modular de gráficos PNG (460 archivos). Bloque C con paleta compartida (`PLTE` + `tRNS`) y sub-bloques con geometría y datos (`IHDR` + `IDAT`).
  - `docs/formats/map_m.md`: Formato de mapas binarios (141 archivos en `m/m/` y `m/m2/`). Capas de tiles de 16×16 píxeles, colisiones, objetos interactivos, decoraciones, enemigos y portales.
- Cómo se verificó:
  - Extracción y decodificación exitosa de texto en español desde `.tdf`.
  - Parseo de coordenadas de `mmi/0`, `mmi/1`, `mmi/8`, `mmi/10`.
  - Reconstrucción de PNG válido a partir de `en/0/01.mpm` comprobada nativamente con biblioteca Pillow (modo indexado P, 10×19 px).
  - Actualizadas como resueltas OQ-001, OQ-002, OQ-003 y OQ-004 en `docs/OPEN_QUESTIONS.md`.
- Pendiente o dudas: Proceder a T2.5 para implementar los parsers en `tools/`.
---

## T1.2 · estado: en curso
- Qué se hizo: Recepción y análisis del primer lote de capturas de referencia directa del emulador en `docs/reference/`:
  - `clase-guerrero.jpg`: Protagonista Lucian (pelo rojo, armadura azul/metálica) en clase Guerrero (mandoble a dos manos con filo azul y guarda dorada).
  - `clase-asesino.jpg`: Protagonista Lucian en clase Asesino (doble empuñadura de dagas, armadura liviana y esquiva).
  - `permitir-guardado-3-partidas.jpg`: Sistema original de 3 ranuras de guardado ("Cargar 1", "Cargar 2", "Cargar 3").
  - `permitir-transferir-cosas-entre-partidas-guardadas.jpg`: Mecánica de "Almacenamiento público" que permite transferir oro, consumibles y equipamiento entre diferentes ranuras de guardado (vital para Fase 7 / T7.7).
  - Catalogadas las entidades en `docs/coverage.csv`.
- Cómo se verificó: Inspección visual de las 4 imágenes en `docs/reference/`, registro de atributos clave de diseño y actualización de la matriz de cobertura.
- Pendiente o dudas: Continuar recibiendo capturas de mapas, combates y diálogos a medida que se juegue la sesión.
- Actualización T1.2: Confirmadas las 4 clases jugables de Lucian:
  1. **Guerrero:** Mandoble / armadura pesada (principiantes).
  2. **Caballero:** Espada y escudo / armadura pesada / alta defensa (principiantes).
  3. **Asesino:** Doble daga / armadura ligera / esquiva (expertos).
  4. **Pistolero:** Doble pistola / armadura ligera / ataque a distancia (expertos).
  - Todas añadidas a `docs/coverage.csv`.
- Actualización T1.2 (Clases secretas / New Game+):
  5. **Elemental:** Símbolo púrpura. Magia y habilidades elementales (bloqueada inicialmente, se desbloquea tras finalizar el juego).
  6. **Gunblader:** Símbolo turquesa/cian. Híbrido espada-pistola (bloqueada inicialmente, se desbloquea tras finalizar el juego).
  - Total de clases de Heroes Lore: Zero confirmadas: **6 clases** (4 iniciales + 2 desbloqueables).
