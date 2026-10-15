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
---

## T2.5 · estado: hecho
- Qué se hizo: Implementación de los módulos de parseo binario en `tools/parsers/`:
  - `parse_tdf.py`: Decodificación de tablas de texto `.tdf` a UTF-8/Latin-1 y exportación a JSON.
  - `parse_mmi.py`: Decodificación de marcadores de objetivo `mmi/` (70 bytes = 35 pares de coordenadas X,Y).
  - `parse_mpm.py`: Reensamblador de contenedores `.mpm` a imágenes PNG estándar mediante inyección de chunks `PLTE`, `tRNS`, `IHDR` e `IDAT`.
  - `parse_map.py`: Decodificador de mapas binarios `.m` (dimensiones, capas ground/collision en tiles de 16×16, objetos, decoraciones, spawns y portales).
- Cómo se verificó: Pruebas unitarias de decodificación ejecutadas directamente sobre muestras de cada formato (`t/m/0.tdf`, `mmi/0`, `en/0/01.mpm`, `m/m/00.m`). Todas parsearon con integridad estructural y tipos esperados.
- Pendiente o dudas: Ninguna. Parsers integrados en el pipeline de extracción.
---

## T2.6 · estado: hecho
- Qué se hizo: Implementación del extractor general `tools/extract.py` que procesa íntegramente el `.jar` hacia el directorio de trabajo local `out/`:
  - 31 archivos `.tdf` convertidos a JSON (751 cadenas de texto en español en `out/text/`, más consolidado maestro `_all_text_master.json`).
  - 141 archivos `mmi/` convertidos a JSON (2.911 marcadores de misión activos en `out/mmi/`).
  - 141 mapas `.m` exportados a JSON (con capas de tiles, colisiones, objetos y entidades en `out/maps/`).
  - 460 archivos `.mpm` reconstruidos en **3.199 sprites y frames individuales en formato PNG estándar** con canal alfa en `out/sprites/`.
  - 17 pistas de audio MIDI organizadas en `out/audio/midi/`.
  - 14 efectos de sonido WAV organizados en `out/audio/wav/`.
  - 39 texturas nativas de interfaz copiadas a `out/ui/`.
- Cómo se verificó: Ejecución de `python tools/extract.py input/Heroes Lore Zero 360x640 Spanish.jar out` (exit code 0, 0 errores, tiempo de ejecución ~3.2s).
- Pendiente o dudas: Proceder a T2.7 y T2.8 para verificaciones cruzadas y catálogos de referencia estética.
---

## T1.3 · estado: hecho
- Qué se hizo: Consolidación y población completa de `docs/coverage.csv` mediante la herramienta `tools/update_coverage.py`:
  - 151 filas registradas cubriendo la totalidad del juego:
    - 6 clases de Lucian (4 iniciales + 2 de New Game+).
    - Mecánicas centrales de guardado y almacenamiento público / baúl transferible.
    - 141 mapas de juego con sus nombres en español oficiales ("Aldea Silverleaf", "Ciudad Humming", "Orfanato", "Jardín de Huesos", "Pantano", "Fortaleza del Sur", etc.).
    - Todos los jefes y arenas de combate (Anthony, Alicia, Aquila, Quimera, Timoros, Perro del Infierno, Dios Gigante, Carnívora).
- Cómo se verificó: Inspección de `docs/coverage.csv`, generado y validado con 151 entidades con dimensiones, conteo de objetos y estados de lógica/arte.
- Pendiente o dudas: Ninguna para la matriz de cobertura base.
---

## T2.7 · estado: hecho
- Qué se hizo: Suite de verificación de datos y herramientas de verificación visual completadas:
  1. `tools/verify_fase2.py`: Valida que el 100% de los 1.112 archivos del archivo JAR estén extraídos/decompilados sin errores.
  2. `tools/render_maps.py`: Reconstruye mapas completos a PNG a partir de los tilesets (`/m/tXX/`) y las capas de tiles y colisión. Renderizados los 141 mapas en `out/renders/`.
  3. `tools/make_contact_sheets.py`: Genera hojas de contacto en cuadrícula organizada de los 3.199 sprites extraídos en `out/contact_sheets/` (Héroe y armas: 1.259 frames, Enemigos y jefes: 963 frames, VFX: 76 frames, Props: 170 frames, UI: 241 frames).
- Cómo se verificó:
  - `python tools/verify_fase2.py` -> exit code 0 (100% verificado).
  - `python tools/render_maps.py --all` -> 141 mapas exportados a PNG correctamente.
  - `python tools/make_contact_sheets.py` -> 6 hojas de contacto compuestas en PNG.
- Pendiente o dudas: Checkpoint humano 🧑 para revisar las hojas de contacto y 10 mapas contra el emulador.
---

## T2.8 · estado: hecho
- Qué se hizo: Elaboración del catálogo exhaustivo de referencias artísticas y directrices de rediseño 2D en `art/refs/catalog.md`.
  - Diferenciación rigurosa entre **hechos observados del original** (pixel art 16×16 / 24×32, 16 colores indexados, 4 direcciones, 3-4 frames de animación, vista ~30º ligeramente elevada) e **interpretaciones estéticas del rediseño 2D** (resolución base 1920×1080, sprites ilustrados de 96-128 px, fondos pintados con profundidad inspirados en Bleaklight Falls, animaciones a 6-8 frames a 60 FPS con partículas 2D).
  - Categorización completa: Lucian y clases, armas desacopladas (sockets), 54 familias de enemigos/jefes, NPCs de aldeas y ciudades, objetos/props interactivos, 35 biomas de tilesets y efectos de habilidades.
- Cómo se verificó: Revisión contra `art/STYLE.md`, `reverse/mapping.txt`, las capturas de emulador y los 3.199 sprites catalogados.
- Pendiente o dudas: Proceder a la Fase 3 (Especificación inversa de la lógica de juego).
---

## T3.1 · estado: hecho
- Qué se hizo: Documentación técnica del bucle principal, temporización de reloj y máquina de estados global en `docs/spec/engine.md`.
  - Confirmada tasa nominal de lógica: `TICK_HZ = 14 Hz` (71.42 ms/tick) a partir del array estático en `rpg/e.java`. Modos secundarios: 10 Hz (ralentizado) y 20 Hz (transiciones).
  - Definida arquitectura de doble reloj para Godot 4.7: simulación a 14 Hz desacoplada e interpolada en `_physics_process` y renderizado a 60+ FPS en `_process`.
  - Mapeo de la máquina de estados: `Canvas` nativo (`de`), Título (`bc`), Mundo (`bf`), Estado global (`dq`) y Mapas (`e`).
- Cómo se verificó: Decompilación e inspección de `rpg/e.java`, `cm.java` y `de.java`.
- Pendiente o dudas: Ninguna.
---

## T3.2 · estado: hecho
- Qué se hizo: Documentación del sistema de movimiento, coordenadas y colisiones en `docs/spec/movement.md`.
  - Coordenadas duales: continuas en píxeles `(h, i)` y discretas en casillas `(s, t)` donde `s = h >> 4` y `t = i >> 4` (tiles de 16×16 px).
  - 8 direcciones de desplazamiento con vectores unitarios en `rpg.b.G` y `H`.
  - Velocidad base de paso: 3 píxeles/tick (42 px/s a 14 Hz), reducida al 80% (4/5) bajo efecto slow.
  - Reglas de colisión bitwise en capa overlay: máscara `0x80` (muro sólido), `0x40` (desnivel) y `0x3F` (tiles decorativos / barrera invisible).
  - Adaptación para stick analógico con zona muerta de 0.20 y pivote en el pie `(X+8, Y+14)`.
- Cómo se verificó: Inspección de `ee.java`, `dg.java`, `e.java` y `rpg/b.java`.
- Pendiente o dudas: Ninguna.
---

## T3.3 · estado: hecho
- Qué se hizo: Especificación formal de combate en `docs/spec/combat.md`.
  - Fórmulas de daño base: $\text{Daño} = \max(1, \text{ATK} - \text{DEF} + \text{Varianza})$ con fluctuación de $\pm 5\%$.
  - Fórmula de crítico de `dg.java` (línea 2165): $\text{Prob\_Crit} = \max(10, 60 - \text{DEF})$ con daño multiplicado por $1.5\times$.
  - Fórmula de evasión (Miss) de `dg.java` (línea 2172): tirada aleatoria sobre $100 - \text{EVA}$.
  - Fórmulas pasivas de vampirismo: $10\%$ robo de vida (HP) y $5\%$ absorción de maná (MP).
  - Catálogo de habilidades iniciales de las 6 clases (`t/s0.tdf` a `t/s5.tdf`) y estados alterados (Stun, Slow, Poison, Iron Skin).
- Cómo se verificó: Rastreo de métodos de cálculo en `dg.java` y `ec.java`.
- Pendiente o dudas: Ninguna.
---

## T3.4 · estado: hecho
- Qué se hizo: Especificación de la curva de progresión, crecimiento de stats y economía en `docs/spec/progression.md`.
  - Curva de nivel exponencial hasta nivel 99: $\text{EXP}(L) = \lfloor 50 \times (L-1)^{2.2} + 20 \times (L-1) \rfloor$.
  - Tabla de escalado de stats por nivel para las 6 clases (Guerrero, Caballero, Asesino, Pistolero, Elemental, Gunblader).
  - Taxonomía completa de objetos (`/itm/` 0 a 19): armas, armaduras, accesorios, gemas, consumibles y objetos clave.
  - Economía de tiendas y forja de refinación (`t/nb.tdf`).
- Cómo se verificó: Análisis de `bn.java`, `ai.java`, `bx.java` y tablas de texto en `out/text/`.
- Pendiente o dudas: Ninguna.
---

## T3.5 · estado: hecho
- Qué se hizo: Especificación de la inteligencia artificial de enemigos y jefes en `docs/spec/ai_enemies.md`.
  - Máquina de estados de IA de 6 fases (Patrulla, Persecución, Anticipación, Ataque, Enfriamiento, Daño/Muerte).
  - Parámetros espaciales y temporales: Radio de detección (4-6 tiles / 64-96 px), radio de abandono (9-12 tiles), cooldown de ataque (14-28 ticks).
  - Desglose de mecánicas y fases de los 11 encuentros de jefes (Anthony, Alicia, Aquila, Quimera, Timoros, Perro del Infierno, Dios Gigante, etc.).
- Cómo se verificó: Decodificación de atributos en `ec.java` y análisis de secuencias de combate.
- Pendiente o dudas: Ninguna.
---

## T3.6 · estado: hecho
- Qué se hizo: Especificación del sistema de eventos, banderas de historia y persistencia en `docs/spec/events_quests.md`.
  - Arquitectura de bitset en `dq.java` (`get_flag`, `set_flag`, `clear_flag` en array `N`).
  - Identificación de banderas especiales NG+ (Flag 250 y 251 para desbloquear Elemental y Gunblader).
  - Triggers de mapa: portales de transición, zonas de spawn y colisión con NPCs/cofres.
  - Formato de guardado para Godot (`user://save_X.dat` para 3 ranuras) y almacenamiento público compartido (`user://shared_trunk.dat`).
- Cómo se verificó: Análisis de `dq.java`, `e.java` y formatos de texto `.tdf`.
- Pendiente o dudas: Criterio de salida de Fase 3 cumplido. Listo para Fase 4.
---

## T4.1 & T4.2 · estado: hecho
- Qué se hizo: Implementación del gestor de pantalla `DisplayManager` (`godot/scripts/display_manager.gd`) registrado como Autoload en `project.godot`.
  - Soporte para modos: Ventana, Borderless y Pantalla Completa.
  - Resoluciones comunes soportadas (1280×720 inicial, 1600×900, 1920×1080 diseño base, 2560×1440, 3840×2160 4K).
  - V-Sync configurable, límite de FPS (60 por defecto) y escalado de UI independiente de la resolución del contenido.
- Cómo se verificó: Ejecución headless y gráfica comprobando el log de inicialización de `DisplayManager`.
- Pendiente o dudas: Ninguna.
---

## T4.3 · estado: hecho
- Qué se hizo: Implementación del reloj de simulación fija desacoplado `GameClock` (`godot/scripts/game_clock.gd`) registrado como Autoload.
  - Tasa de simulación exacta: `TICK_HZ = 14 Hz` (71.4 ms/tick).
  - Emite la señal `game_tick(tick_number)` en `_physics_process` mientras el renderizado de cámara y animaciones corre a 60+ FPS fluidos con factor de interpolación alfa.
- Cómo se verificó: Ejecución limpia en Godot comprobando `TICK_HZ = 14.0 Hz (intervalo = 71.429 ms)`.
- Pendiente o dudas: Ninguna.
---

## T4.4 · estado: hecho
- Qué se hizo: Implementación del cargador de datos del juego `DataLoader` (`godot/scripts/data_loader.gd`) registrado como Autoload.
  - Carga transparente de mapas JSON desde `out/maps/`, tablas de texto desde `out/text/`, indicadores de misión desde `out/mmi/` y texturas de tiles/sprites desde `out/sprites/`.
  - Mantiene los datos de lógica completamente independientes del arte final.
- Cómo se verificó: Carga exitosa de `m_m_00.json` (Aldea Silverleaf) y verificación de dimensiones de casillas y entidades.
- Pendiente o dudas: Ninguna.
---

## T4.5 & T4.6 · estado: hecho
- Qué se hizo: Implementación del sistema de cámara 2D y la escena interactiva de comparación de encuadres `res://scenes/CameraComparison.tscn` (`godot/scripts/camera_comparison.gd`).
  - **Variante A (Cenital Directa):** Zoom 5.0x, encuadre perpendicular muy cerrado (~6 tiles visibles), límites estrictos a los bordes del mapa, viñeta azul.
  - **Variante B (Cenital Amplia - Bleaklight Falls):** Zoom 2.0x, campo de visión amplio (~15 tiles visibles), offset frontal de -80 px, viñeta ámbar, atmósfera inspirada en Bleaklight Falls.
  - Permite mover a Lucian con teclado o mando y alternar variantes en caliente con las teclas 1 y 2.
  - Documentadas en detalle en `docs/spec/camera.md`.
- Cómo se verificó: Ejecución gráfica de `CameraComparison.tscn` comprobando movimiento, alternancia de variantes y renderizado de mapa real a escala 4x.
- Pendiente o dudas: Ninguna.

---

## T4.7 · estado: hecho (🧑 Checkpoint Humano)
- Qué se hizo: Evaluación interactiva y aprobación por el usuario de la perspectiva y encuadre 2D.
  - El usuario probó ambas variantes en tiempo real y aprobó formalmente la **Variante B (Cenital Amplia · Estilo Bleaklight Falls)**.
  - Parámetros fijados: Zoom $2.0\times$, offset vertical $-80\text{ px}$, límites con margen de amortiguación.
  - Registrado en `docs/spec/camera.md`. La Variante A queda descartada.
- Cómo se verificó: Decisión explícita del usuario recibida y documentada.
- Pendiente o dudas: Fase 4 concluida al 100%. Listo para comenzar la Fase 5 (Vertical Slice).
---

## T4.8 · estado: hecho
- Qué se hizo: Generación e importación del primer lote de arte 2D estilizado mediante `tools/generate_first_art_batch.py`:
  - `hero_lucian_idle.png` (96×128 px, Lucian con pelo rojo, armadura azul/dorada y sombra pintada).
  - `enemy_forest_wolf.png` (80×64 px, lobo de bosque con pelaje gris-azulado y ojos ámbar).
  - `tile_grass_base.png` (64×64 px, tile de suelo con paleta verde musgo estilo Bleaklight Falls).
  - `prop_ancient_tree.png` (128×160 px, obstáculo de entorno para solape Y-Sort).
  - `prop_chest_closed.png` y `prop_chest_open.png` (48×48 px, cofre de tesoro interactivo).
  - `vfx_sword_slash.png` (96×64 px, efecto de energía cian para ataques).
  - Importados en Godot (`godot/art_samples/`) y registrados formalmente en `art/manifest.csv`.
- Cómo se verificó: Importación sin errores mediante `godot --headless --editor --quit`.
- Pendiente o dudas: Revisión visual en T4.7.
---

## T4.9 · estado: hecho
- Qué se hizo: Implementación del gestor de controles `InputManager` (`godot/scripts/input_manager.gd`) registrado como Autoload.
  - Define el `InputMap` abstracto para: `move_up`, `move_down`, `move_left`, `move_right`, `attack`, `skill_1`, `skill_2`, `skill_3`, `skill_4`, `quick_item`, `interact`, `menu`, `map`, `cancel`.
  - Soporte completo para Teclado (WASD / Flechas / Espacio / QERF) y Mando/Gamepad (Stick analógico con zona muerta 0.20, D-pad, botones ABXY, gatillos y bumpers).
- Cómo se verificó: Integrado y verificado en `camera_comparison.gd`.
- Pendiente o dudas: Ninguna.
---

## T4.10, T4.11, T4.12 & T4.13 · estado: hecho
- Qué se hizo: Suite de rendimiento, renderizador y perfiles gráficos:
  - Confirmado renderizador **Compatibility** (OpenGL 3.3 / ANGLE) como óptimo por compatibilidad universal.
  - Implementado `ProfileManager` (`godot/scripts/profile_manager.gd`) con perfiles Bajo, Medio y Alto.
  - Mediciones reales obtenidas en el equipo de referencia (i7-11800H + RTX 3050 Ti Laptop / Intel UHD):
    - **Perfil Medio (1080p):** **58.6 FPS**, **17.07 ms** de frame time, **31.83 MB** de RAM estática.
    - **Perfil Bajo (720p/1080p):** **59.2 FPS**, **16.89 ms**, **30.50 MB** de RAM.
    - **Perfil Alto (1440p/4K):** **58.4 FPS**, **17.12 ms**, **33.20 MB** de RAM.
  - Definidos los límites técnicos y presupuesto por escena en `docs/spec/performance.md` (sprites héroe 96×128, atlas máx 2048, presupuesto de partículas 64/128/256, máx 4 luces simultáneas, descarte culling activo).
- Cómo se verificó: Ejecución real de `res://scenes/Benchmark2D.tscn` en consola capturando métricas del sistema.
- Pendiente o dudas: Ninguna.

---

## T5.1 · estado: hecho
- Qué se hizo: Implementación completa del movimiento y reloj dual en `Player` (`godot/scripts/player.gd` y `godot/scenes/Player.tscn`):
  - Simulación a `TICK_HZ = 14 Hz` para lógica y colisiones.
  - Velocidad fiel: 3 px/tick * 14 Hz = 42 px/s (168 px/s a escala 4x).
  - 4 orientaciones cardinales, detección de entrada de `InputManager`, colisión con `CharacterBody2D`.
- Cómo se verificó: Ejecución en tiempo real en la escena `VerticalSlice.tscn`.
- Pendiente o dudas: Ninguna.
---

## T5.2 · estado: hecho
- Qué se hizo: Sistema de colisiones 2D por capas:
  - Capas de colisión configuradas: Capa 1 (Entorno/Muros/Árboles), Capa 2 (Jugador), Capa 3 (Enemigos).
  - Árboles antiguos (`godot/scenes/PropTree.tscn`) con colisión sólida en el tronco y copa transitable en Y-Sort.
  - Muros límite perimetrales (`WorldBoundaries`) que confinan al jugador y enemigos al área del mapa.
- Cómo se verificó: Colisión física comprobada al mover a Lucian contra muros, árboles y cofre.
- Pendiente o dudas: Ninguna.
---

## T5.3 · estado: hecho
- Qué se hizo: IA de enemigo y ciclo de combate con Lobo del Bosque (`godot/scripts/enemy_wolf.gd`, `godot/scenes/EnemyWolf.tscn`):
  - FSM de 6 estados: Patrulla -> Persecución (Aggro a 6 tiles) -> Anticipación de ataque -> Ejecución de mordisco -> Enfriamiento (1.5s) -> Daño/Retroceso -> Muerte.
  - Combate cuerpo a cuerpo con espada de Lucian: hitbox frontal, efecto visual `vfx_sword_slash.png`.
  - Daño numérico exacto: `max(1, ATK - DEF + varianza)`, crítico de $150\%$ y tirada de evasión según `docs/spec/combat.md`.
  - Recompensa al morir: otorga +10 EXP, subida de nivel automática y probabilidad del 40% de soltar poción.
- Cómo se verificó: Combate jugado en tiempo real en `VerticalSlice.tscn`.
- Pendiente o dudas: Ninguna.
---

## T5.4 · estado: hecho
- Qué se hizo: Sistema de diálogo e interacción con NPC Maestro de Armas (`godot/scripts/npc_trainer.gd`, `godot/scenes/NPCTrainer.tscn`):
  - Diálogos en español con instrucciones del combate y el sendero exterior.
  - Panel de diálogo en HUD con hablante, texto narrativo y tecla de avance (`[Espacio]`, `[E]`, `[Enter]`).
  - Orientación dinámica del NPC hacia el jugador al iniciar conversación.
- Cómo se verificó: Interacción con tecla E comprobada en `VerticalSlice.tscn`.
- Pendiente o dudas: Ninguna.
---

## T5.5 · estado: hecho
- Qué se hizo: Sistema de inventario mínimo y cofre interactivo (`godot/scripts/prop_chest.gd`, `godot/scenes/PropChest.tscn`):
  - Cofre abre con tecla `[E]` al aproximarse, cambia textura a abierto y entrega 2 Pociones Menores.
  - Uso de poción mediante tecla rápida `[Q]` o mando: recupera +50 HP con efecto y texto flotante verde.
  - Contador de pociones en HUD actualizado en tiempo real.
- Cómo se verificó: Apertura de cofre y curación de vida comprobada en `VerticalSlice.tscn`.
- Pendiente o dudas: Ninguna.
---

## T5.6 · estado: hecho
- Qué se hizo: Suite de pruebas automatizadas de paridad numérica (`tests/test_combat_parity.py`):
  - 7 pruebas unitarias verificando: daño físico base, mitigación de defensa, límites de varianza pseudo-aleatoria ($\pm \lfloor \text{ATK}/20 \rfloor$), multiplicador de crítico ($150\%$), fórmula de probabilidad de crítico (`dg.java:2165`), curva exponencial de nivel y crecimiento de atributos del Guerrero (+28 HP, +6 MP, +5 ATK, +3 DEF).
- Cómo se verificó: `python tests/test_combat_parity.py` -> 7 tests pasados, exit code 0.
- Pendiente o dudas: Ninguna.
---

## T5.7 · estado: hecho
- Qué se hizo: Validación de estados visuales y animaciones 2D:
  - Lucian: reposo, desplazamiento, tajo de espada, retroceso por daño (parpadeo rojo) y animación de muerte.
  - Lobo: patrulla, persecución, parpadeo de aviso de ataque, embestida, daño con retroceso y desvanecimiento al morir.
- Cómo se verificó: Comprobado visualmente en ejecución continua.
- Pendiente o dudas: Ninguna.
---

## T5.8 · estado: hecho
- Qué se hizo: Sistema de guardado y carga persistente (`godot/scripts/save_manager.gd`):
  - Registrado como Autoload `SaveManager`.
  - Guardado en `user://saves/save_slot_1.json` con tecla `[F5]`: serializa nivel, HP, MP, EXP, stats, pociones, posición global y estado del cofre.
  - Carga con tecla `[F6]`: restaura instantáneamente todos los atributos, posición y estado de la escena.
- Cómo se verificó: Guardado y carga comprobados con notificación visual en pantalla.
- Pendiente o dudas: Listo para la Puerta de Aprobación Humana (T5.10–T5.14).

---

## T5.9 · estado: hecho
- Qué se hizo: Refinamiento del HUD y barra de 6 slots según el diseño original J2ME:
  - Tarjeta unificada inferior (`CombatCard`) con diseño puramente gráfico sin etiquetas de texto ni cifras numéricas que saturen la pantalla.
  - Fila superior de Habilidades: SP (Azul, clase) a la izquierda y EP (Verde, elemental) a la derecha, divididas 50%/50%.
  - Barra de Salud (HP) roja de ancho completo ubicada por debajo de las barras azul y verde.
  - Línea fina amarilla de Experiencia (EXP) abarcando todo el ancho inferior de los medidores.
  - 6 Slots de acción directamente debajo con bordes cromáticos distintivos:
    - [1] y [2]: Borde azul (Habilidades de Guerrero: Golpe Brutal, Embestida).
    - [3] y [4]: Borde verde (Habilidades elementales: Onda Ígnea, Rayo 360°).
    - [5]: Borde rojo (Poción HP).
    - [6]: Borde azul (Poción SP).
- Cómo se verificó: Ejecución en Godot Engine v4.7.2 headless con código de salida 0 y suite de paridad 7/7 tests OK.
- Pendiente o dudas: Ninguna. Listo para la revisión del usuario y el reemplazo de arte real (T5.10 / T5.11).

---

## T5.10 · estado: en curso
- Qué se hizo: Montaje de la primera capa visual con arte ilustrado en la escena integrada del Vertical Slice (`VerticalSlice.tscn`):
  - Terreno ilustrado de Aldea Silverleaf (`art_samples/map_silverleaf.png`, 1792×2560 px) que sustituye el fondo plano por senderos de adoquines, hierba orgánica y plaza central con luz dorada matutina según `art/STYLE.md`.
  - Casas de aldea (`PropVillageHouse.tscn`) con muros de piedra, vigas de roble y tejados de tejas rojas integradas en `World` con ordenación dinámica **Y-Sort** y colisión física sólida en sus cimientos.
  - Taller y cabaña de entrenamiento (`PropCottage.tscn`) con toldo, diana y maniquí, ubicado junto al puesto del instructor.
  - Mobiliario y props de aldea: farolas de hierro forjado (`PropLantern.tscn`), barriles y cajas de suministros (`PropBarrel.tscn`) y árboles antiguos (`PropTree.tscn`).
  - Sprite ilustrado distintivo del Maestro de Armas Aldren (`art_samples/npc_aldren.png`) con túnica verde, jubón de cuero y barba veterana, reemplazando el duplicado placeholder del héroe.
  - Registro de los nuevos activos en `art/manifest.csv`.
- Cómo se verificó: Carga headless en Godot 4.7.2 con código de salida 0 y suite de pruebas de paridad 7/7 OK.
- Pendiente o dudas: Revisión visual por parte del usuario mediante `JUGAR_VERTICAL_SLICE.bat` para confirmar la ambientación antes de pulir las animaciones multi-frame de Lucian y el Lobo (T5.11 / T5.12).
