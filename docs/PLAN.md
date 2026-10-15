# Plan 0-100: port fan-made de Heroes Lore: Zero a PC (Godot 4)

Documento de trabajo para un agente de IA · Uso personal · Windows · Godot 4 · Juego 2D de vista cenital inspirado visualmente en Bleaklight Falls · Arte ilustrado/hand-painted estilizado · Toda la historia y el contenido original confirmado en la versión completa

**Requisitos principales aprobados:** el juego será 2D, con vista cenital o ligeramente elevada, composición de escenarios detallada y una estética ilustrada moderna inspirada en rasgos generales de Bleaklight Falls: lectura clara del terreno, ambientes expresivos, capas visuales y arte dibujado. La referencia es orientativa: no se copian sus sprites, escenarios, interfaz ni diseños. El arte nuevo se genera con IA y lo retoca manualmente el usuario antes de su aprobación e integración. El proyecto debe funcionar en PC modestos y portátiles, admitir salida hasta 4K y ofrecer perfiles gráficos escalables. La resolución 4K de salida no implica exigir recursos renderizados a 4K ni garantizar 60 FPS en todos los equipos; se medirán objetivos por hardware. La versión completa debe incluir toda la historia y todo el contenido original verificado, no solo la historia principal ni una selección reducida.

## 0. Cómo usar este documento

Este plan está escrito para que un agente de IA lo ejecute fase por fase. Cada fase tiene tareas numeradas (T2.3, T5.1…), entregables y un criterio de aceptación comprobable. El marcador 🧑 indica un punto donde hace falta una persona (grabar gameplay, juzgar el feeling, confirmar visualmente).

Qué se sabe del juego (inspección del .jar, sin decodificar aún):

- MIDlet Heroes Lore Zero v4.4.45, versión modificada (360x640, español), 1.145 archivos.
- 144 clases Java ofuscadas; el punto de entrada es `rpg/RPGHeroEx`.
- 460 archivos `.mpm` (formato propio; son gráficos, animaciones y datos, hipótesis), \~140 `.m` (mapas, hipótesis) en `m/m` y `m/m2`, 141 archivos `mmi` de 70 bytes (atributos de tiles o colisión, hipótesis), 31 `.tdf` (texto y misiones, hipótesis).
- 16 MIDI en `snd/b`, 14 WAV de 8 kHz, 8 bits, mono en `snd/e`.
- 39 PNG solo de UI en la raíz y `sks/`. Fuente propia (`ftd/table`, `dotFontSmall.dat`).
- Carpetas probables: `hero/` (héroe, armas, equipo), `en/` (enemigos y stats), `itm/` (objetos), `img/`, `s/`, `t/`.

Todo lo marcado como hipótesis debe verificarse en la Fase 2 leyendo el código decompilado. Nunca se asume. El arte original y sus sprites/tiles sirven para estudiar diseños, paletas, animaciones, hitboxes, distribución y atmósfera. La presentación final será 2D renovada: los recursos originales podrán usarse como referencia técnica, pero el arte nuevo debe generarse, retocarse y aprobarse según la guía visual, sin asumir que extraer un sprite equivale a tener un asset final aprobado. Los datos de mapas, stats, animaciones, hitboxes, textos y progresión se usan como fuente de paridad y se verifican contra el juego original.

## 1. Requisitos y decisiones del proyecto

| Tema | Decisión |
| --- | --- |
| Motor | Godot 4.x estable. Fijar una versión y sus plantillas de exportación antes del desarrollo real; no actualizar el motor en mitad de una fase sin ejecutar la batería de pruebas. |
| Plataforma | Windows, con atención explícita a portátiles y PC de gama baja o media. |
| Dimensión y perspectiva | Juego 2D con vista cenital / top-down, ligeramente elevada en la composición del arte cuando proceda. No se construirán escenarios ni personajes 3D como base del proyecto. La cámara y el encuadre se fijarán mediante un prototipo 2D en la Fase 4. |
| Estilo visual | Arte 2D ilustrado y estilizado, con apariencia pintada a mano, escenarios con personalidad, vegetación y elementos de entorno detallados pero legibles, paleta coherente, sombras pintadas y capas para sugerir profundidad. Bleaklight Falls es referencia de perspectiva, composición y sensación visual general, no una plantilla para copiar assets. La identidad de Heroes Lore: Zero debe seguir siendo reconocible. |
| Presentación en PC | Orientación horizontal como objetivo para PC, sin estirar el arte ni alterar la distribución jugable. Definir reglas para mapas menores que el encuadre y validar cómo adaptar el original vertical 360×640 sin inventar zonas jugables. |
| Resolución y rendimiento | Compatibilidad con salida hasta 4K. Separar resolución de pantalla, escala del viewport 2D, escala de texturas y escala de UI. Buscar 1080p/60 FPS en el equipo mínimo de referencia con perfil bajo, sujeto a medición; medir salida 4K/60 FPS en equipos recomendados cuando sea viable. No prometer rendimiento universal sin pruebas. |
| Escalabilidad | Perfiles Bajo, Medio y Alto. Ajustar efectos, iluminación 2D, partículas, filtros, resolución/escala de render, densidad de elementos decorativos y efectos de postprocesado según sea necesario. No reducir legibilidad de personajes, proyectiles, colisiones o UI al bajar calidad. |
| Renderizador | Partir de Godot Compatibility como candidato por su orientación a hardware amplio; comparar con Mobile en una escena 2D representativa si se usan luces, shaders o efectos que lo justifiquen. Elegir con mediciones y documentar la decisión en `docs/spec/performance.md`. No añadir complejidad gráfica que no mejore claramente el resultado. |
| Arte nuevo | Flujo IA → selección → retoque manual del usuario → limpieza de imagen y animación → preparación de spritesheets/atlases → prueba en Godot → aprobación. Los recursos originales son referencia de diseño y estructura; el arte final debe cumplir `art/STYLE.md`. |
| Animación | Sprites 2D por fotogramas como método principal. `AnimatedSprite2D`, `SpriteFrames`, `AnimationPlayer` y/o técnicas de animación por partes se usarán según lo que resulte más fiable para cada recurso. La salida de IA debe corregirse manualmente para mantener identidad, silueta, proporciones y continuidad entre frames. |
| Control | Mando como control principal, teclado como respaldo y ratón cuando sea útil en menús. Conservar las reglas de movimiento del original como referencia; la entrada analógica se adapta a las direcciones y al modelo de movimiento verificados, sin alterar silenciosamente el combate. |
| Audio | Mejorado: música y efectos limpios, con interruptor para el audio original cuando sea técnicamente viable. |
| Calidad de vida | Guardado libre en cualquier momento, minimapa y marcadores de misión mejorados. |
| Alcance de la versión completa | Toda la historia y todo el contenido original confirmado en la versión de referencia: mapas, misiones, diálogos, NPC, enemigos, jefes, objetos, equipo, habilidades, minijuegos, secretos y extras que existan. Ninguna categoría original se descarta simplemente por coste; se puede desarrollar por entregas internas, pero la versión 1.0 no se declara completa hasta cubrirla. |
| Fidelidad | Conservar historia, textos, distribución de mapas, stats, fórmulas y progresión, salvo diferencias técnicas documentadas y aprobadas. Los rediseños 2D deben conservar rasgos, colores, siluetas y equipo que permitan reconocer personajes y criaturas. |
| Distribución | Solo uso personal. Aun así, el `.jar`, los assets convertidos y el arte generado no se suben a git. |

## 2. Reglas de trabajo del agente (metodología)

1. **Los archivos son la memoria.** Antes de empezar cada sesión, leer `docs/PLAN.md`, `docs/PROGRESS.md` y `docs/OPEN_QUESTIONS.md`. Al terminar, actualizarlos.
2. **Una tarea, un commit.** Ciclo: leer tarea → plan de 3-5 líneas → implementar → verificar con comandos → commit con el ID de tarea → anotar en PROGRESS.md.
3. **Verificar antes de avanzar.** No se pasa de fase hasta cumplir su criterio de aceptación. Las verificaciones son scripts que se pueden relanzar (`tools/verify_fase2.py`, etc.).
4. **No inventar.** Los formatos y las fórmulas se deducen del código decompilado y de comparar con el emulador. Si hay duda, se anota en OPEN\_QUESTIONS.md y se sigue con otra tarea.
5. **Dos vías separadas.** Vía A: herramientas en Python fuera de Godot (extractor, conversores, verificadores). Vía B: proyecto Godot que solo consume datos ya convertidos.
6. **Todo guiado por datos.** Nada de stats, textos ni mapas escritos a mano en el código de Godot.
7. **Godot por línea de comandos.** Las escenas (`.tscn`) y scripts (`.gd`) son texto, así que el agente los edita directamente y ejecuta `godot --headless --path godot/ ...` para comprobar errores y correr tests.
8. **MCP es opcional.** Existen servidores MCP comunitarios para Godot (Coding-Solo/godot-mcp, GDAI MCP, bradypp/godot-mcp y satelliteoflove/godot-mcp, este último con control del editor e inyección de input para pruebas). Ayudan a controlar el editor y a probar el juego en ejecución, pero el plan funciona con solo shell y archivos. Revisar el README de cada uno antes de instalarlo, porque su mantenimiento varía.
9. **Capacidades mínimas del agente:** shell en Windows, lectura y escritura de archivos, ejecutar Python, Java y Godot. Si el agente no puede ver imágenes, los checkpoints 🧑 sustituyen toda verificación visual.
10. **Tests.** Usar GUT o gdUnit4 para lógica en Godot y `pytest` para las herramientas Python.

**Regla 11 · Arte generado con IA.** Todo recurso visual generado se registra en `art/manifest.csv` con, como mínimo: ID, categoría, herramienta/modelo y versión, prompt, semilla si existe, referencias utilizadas, licencia/términos revisados, archivos de origen, estado del retoque, dimensiones, número de frames si corresponde, formato de exportación y aprobación. No se inventan metadatos; si no están disponibles, anotar `no disponible`.

**Regla 12 · Flujo obligatorio del arte 2D.** Referencia → generación con IA → selección → retoque manual del usuario → limpieza de transparencia, bordes, anatomía, paleta y proporciones → preparación de frames o tiles → prueba dentro del juego → integración → aprobación. Para sprites animados, comprobar continuidad visual entre frames, pivote/punto de apoyo, escala y tiempo de animación. El agente organiza fuentes, atlas, nombres y verificaciones, pero no marca un recurso como aprobado por el usuario.

**Regla 13 · Consistencia visual.** Antes de producir arte en volumen, crear y aprobar `art/STYLE.md` con la perspectiva cenital, referencias permitidas, paleta por bioma, lenguaje de formas, nivel de detalle, contraste, iluminación pintada, escala de personajes, tamaños base de sprites, reglas de contorno, sombras, densidad de escenario, tratamiento de vegetación, efectos y UI. Bleaklight Falls se utiliza como referencia de alto nivel para composición y lectura de la vista cenital; no se copian directamente personajes, sprites, mapas, interfaz ni recursos propietarios. El arte debe mantener la identidad de Heroes Lore: Zero.

**Regla 14 · Umbral de integración 2D.** Ningún recurso entra al juego solo porque lo haya generado la IA. Debe tener transparencia limpia cuando corresponda, bordes sin artefactos, tamaño y pivote coherentes, silueta legible en el tamaño de juego, paleta compatible y exportación en formato adecuado (preferentemente PNG/WebP según compatibilidad y uso; conservar fuentes editables). Los sprites animados necesitan frames coherentes y temporización revisada; los tiles necesitan bordes que conecten sin costuras; los elementos superpuestos necesitan capas y orden de dibujo correctos. Cada recurso debe probarse dentro del mapa y la cámara definitivos.

**Regla 15 · Rendimiento por perfiles de hardware.** No se usa “4K a 60 FPS” como criterio único. Separar resolución de salida, escala del viewport 2D, dimensiones de texturas y escala de UI. Registrar pruebas en al menos un equipo modesto y otro recomendado cuando estén disponibles. Guardar resultados y especificaciones reales en `docs/spec/performance.md`; no inventar características de hardware. Si un equipo no está disponible para prueba, dejarlo como pendiente y nunca como aprobado.

**Regla 16 · Alcance completo, no recortado.** El objetivo de la versión 1.0 es reproducir toda la historia y todo el contenido original confirmado. El vertical slice sirve para validar tecnología y sensación de juego, no para limitar el alcance final. Toda entidad o actividad descubierta durante la ingeniería inversa se registra en `docs/coverage.csv`; las entradas dudosas se investigan y no se eliminan por conveniencia.

**Regla 17 · Decisiones de alto impacto.** Registrar en `docs/DECISIONS.md` las decisiones que afecten a perspectiva/encuadre, formato de mapas, tilesets, capas y orden de dibujo, hitboxes, pipeline de sprites, guardados y compatibilidad de hardware. Cada entrada incluye contexto, decisión, alternativas, evidencia de prueba y tareas afectadas si cambia.

Plantilla de entrada en `docs/PROGRESS.md`:

```
## T2.3 · estado: hecho | en curso | bloqueado
- Qué se hizo:
- Cómo se verificó (comando y resultado):
- Pendiente o dudas (→ OPEN_QUESTIONS.md):
```

## 3. Estructura del repositorio

```text
heroes-port/
  input/            # el .jar original (en .gitignore)
  reverse/          # clases decompiladas y mapping.txt
  docs/
    PLAN.md  PROGRESS.md  OPEN_QUESTIONS.md  DECISIONS.md
    formats/        # especificación de formatos binarios
    spec/           # especificación inversa de combate, IA, misiones, stats, cámara y rendimiento
      content_scope.md  performance.md  camera.md
    gates/
      vertical_slice_approval.md  # aprobación explícita antes de producción masiva
    reference/      # capturas, vídeos y notas de referencia
    coverage.csv    # cobertura de contenido + estados de implementación y arte
  tools/            # extractor, conversores y verificadores Python
  out/              # datos extraídos/conversos: mapas, tablas, texto, MIDI y WAV (en .gitignore)
  art/
    STYLE.md        # biblia visual 2D aprobada e inspirada a alto nivel en la referencia
    manifest.csv    # procedencia, prompts, retoque, dimensiones, frames, QA y aprobación
    refs/           # referencias originales, capturas y hojas de diseño
    concepts/       # imágenes y conceptos generados con IA
    raw/            # salidas sin retocar
    work/           # archivos fuente editables y retoque manual
    sheets/         # spritesheets, atlas y tilesheets en preparación
    final/          # sprites, tiles, efectos y UI aprobados para el juego
  godot/            # proyecto Godot 4 2D, escenas y scripts
  tests/            # pruebas de lógica, importación, mapas y regresión
```

## 4. Fase 0 · Preparación del entorno (0 → 5 %)

- **T0.1** Instalar mediante winget o instaladores oficiales: Git, Python 3.11 o superior, JDK, Godot 4.x, FFmpeg, FluidSynth, ImHex, Vineflower o CFR, un editor de imágenes 2D (por ejemplo Krita o GIMP), las herramientas de generación de imágenes que se elijan tras revisar sus licencias y un emulador J2ME de PC (FreeJ2ME-Plus o KEmulator). Blender es opcional, no una dependencia del arte principal.
- **T0.2** Crear el repositorio con la estructura de la sección 3, `.gitignore` (input, out, reverse, arte fuente privado si corresponde) y los documentos base de seguimiento, decisiones, alcance y rendimiento.
- **T0.3** Copiar el `.jar` a `input/`, calcular su SHA-256 y registrarlo en la documentación.
- **T0.4** Crear el proyecto Godot 4 2D vacío y comprobar que `godot --headless --quit` termina sin errores.
- **T0.5** Validar un flujo mínimo IA → retoque en editor 2D → PNG con transparencia → importación en Godot → visualización a diferentes escalas. Probar también el flujo de creación/edición de un spritesheet y de un tilesheet.
- **T0.6** Crear una plantilla de `art/manifest.csv` con procedencia, licencia, prompt disponible, retoque, dimensiones, frames, formato, prueba en escena y aprobación. Crear un borrador de `art/STYLE.md` que describa la nueva dirección visual 2D.
- **T0.7** Crear `docs/DECISIONS.md`, `docs/spec/performance.md` y `docs/spec/content_scope.md`. En `content_scope.md`, definir la matriz inicial del contenido e indicar las hipótesis por verificar en el `.jar`.
- **T0.8** Registrar las especificaciones reales de los equipos de prueba disponibles (CPU, GPU/gráfica integrada, RAM, resolución de pantalla y sistema operativo). Definir provisionalmente un equipo mínimo y uno recomendado sin inventar componentes; si solo hay un equipo, documentar la limitación.
- **T0.9** Preparar una escena 2D de benchmark con un mapa de tiles, personaje animado, enemigos, elementos superpuestos, partículas y los efectos 2D que se estén considerando. Esta escena servirá para comparar renderer, perfiles y resolución de salida.

**Criterio de salida:** todas las herramientas responden a sus comandos de versión, el repositorio tiene su primer commit, el flujo de imagen 2D se valida dentro de Godot y existen los documentos de alcance, decisiones, estilo y rendimiento. Las muestras artísticas requieren aprobación humana.

## 5. Fase 1 · Verdad de referencia con emulador (5 → 12 %)

- **T1.1** Ejecutar el .jar en el emulador en 360x640.
- **T1.2** 🧑 Grabar una partida completa (video con inputs visibles) y capturas de cada mapa, jefe y minijuego. Guardar en `docs/reference/`.
- **T1.3** Rellenar `docs/coverage.csv` con una fila por mapa, enemigo, jefe, NPC importante, objeto, minijuego y misión, con columna de estado.
- **T1.4** Medir la tasa de lógica original (ticks por segundo) con el video y anotarla como `TICK_HZ` provisional.

Criterio: existe material de referencia para toda la historia y `coverage.csv` tiene una fila por cada contenido visto. Se incluyen de forma explícita los minijuegos, los extras y las rutas opcionales que se hayan confirmado en la versión de referencia, porque el objetivo final es cubrir el contenido completo.

## 6. Fase 2 · Ingeniería inversa y extractor (12 → 30 %)

- **T2.1** Inventariar el .jar (tamaño, extensión, hash por archivo) en `docs/inventory.csv`.
- **T2.2** Decompilar todas las clases a `reverse/decompiled/` y comprobar que compila o al menos que se lee.
- **T2.3** Renombrar clases y métodos ofuscados según su función en `reverse/mapping.txt`. Empezar por `rpg/RPGHeroEx` y seguir las llamadas hasta el cargador de recursos, la clase que dibuja, la lógica de mapas y el combate.
- **T2.4** Localizar cómo se lee cada tipo de archivo (secuencias de lectura de bytes, shorts y strings) y escribir `docs/formats/<formato>.md` con la estructura campo por campo.
- **T2.5** Implementar parsers en Python, en este orden: `.mpm` (imágenes, paletas, animaciones, hitboxes), paleta `hero/h.p`, mapas `.m`, atributos `mmi`, `.tdf`, tablas de objetos y enemigos, datos de héroe y armas, fuente `ftd/table`, `s/cif` y `en/cif`.
- **T2.6** Exportador `python tools/extract.py input/juego.jar out/` que genere:
  - Sprites originales en PNG (solo referencia de diseño) con un JSON de animaciones (frames, offsets, duración, hitboxes).
  - Mapas en JSON (capas, tiles, colisión, eventos, NPC, portales, texto).
  - Texto en JSON en español.
  - Tablas de datos (objetos, enemigos, héroe, habilidades) en JSON.
  - Música MIDI y efectos WAV copiados tal cual para la Fase 7.
- **T2.7** Verificadores: ningún archivo sin parsear, hojas de contacto (contact sheets) con todos los sprites y renders de cada mapa para comparar con las capturas de la Fase 1.
- **T2.8** Preparar referencias artísticas por categorías: héroe, NPC, enemigos, jefes, armas/equipo, objetos, tiles/escenarios y efectos. Registrar rasgos reconocibles, dirección de lectura, paleta, proporciones y animaciones; distinguir los hechos observados de las interpretaciones estéticas del rediseño 2D.

Criterio: `tools/verify_fase2.py` informa 100 % de archivos del .jar parseados sin errores y todos los mapas se renderizan. 🧑 Revisar las hojas de contacto y 10 mapas contra el emulador. Las hojas de referencia permiten identificar los rasgos que deben conservarse y preparar muestras coherentes con el estilo 2D ilustrado aprobado; la validación visual de las muestras sigue siendo un checkpoint humano.

## 7. Fase 3 · Especificación inversa de la lógica (30 → 40 %)

- **T3.1** Documentar el bucle principal, la máquina de estados y la tasa de ticks real (actualizar `TICK_HZ`).
- **T3.2** Documentar el movimiento original: por casillas o píxeles, velocidades, direcciones disponibles, tamaño de tile, límites del mapa, puntos de apoyo del sprite y reglas de colisión. El mando puede leer un stick analógico, pero la interpretación de ese input debe respetar el comportamiento original verificado; cualquier libertad de movimiento añadida se documenta y se prueba como cambio de control.
- **T3.3** Combate: fórmulas de daño, defensa, crítico, esquiva, ataque a distancia, habilidades, costes, cooldowns y estados alterados. Validar contra datos reales de las tablas y secuencias observadas.
- **T3.4** Progresión: curva de experiencia, subida de stats, equipo, drops, precios y tiendas.
- **T3.5** IA de enemigos y jefes: patrones, rangos, tiempos, fases, distancias de detección y reglas de ataque.
- **T3.6** Sistema de eventos y misiones: cómo los mapas y los `.tdf` disparan diálogos, flags y cinemáticas, además del formato de guardado original.
- **T3.7** Opcional: instrumentar el original (emulador o recompilación con un shim MIDP) para registrar trazas de referencia (HP, posición, flags por tick) con semilla de azar fija.

**Entregable:** `docs/spec/*.md` con fórmulas en pseudocódigo, supuestos explícitos y tablas de ejemplo.

**Criterio:** otra persona podría implementar el combate y las misiones con esos documentos. 🧑 Revisar dudas abiertas en `docs/OPEN_QUESTIONS.md`.

## 8. Fase 4 · Esqueleto en Godot y presentación 2D (40 → 48 %)

- **T4.1** Configurar la presentación horizontal para Windows y escalas de ventana comunes. Establecer un viewport lógico 2D, filtrado de texturas y modo de escalado apropiados para arte ilustrado detallado; no imponer pixel-art ni filtro sharp-bilinear si la guía visual no lo requiere. Separar escala de contenido y escala de UI. Mantener las proporciones de los mapas y no estirar sprites para llenar pantalla.
- **T4.2** Añadir opciones de ventana: pantalla completa, borderless, vsync, límite de FPS (60 por defecto), escalado de UI y, si resulta necesario, escala de render/viewport.
- **T4.3** Implementar la simulación a `TICK_HZ` fijo si la referencia lo necesita, separada del render y con actualización visual estable. Documentar qué sistemas dependen de ticks de juego y cuáles del delta de render.
- **T4.4** Crear el cargador de datos que lee `out/`: tiles, capas, colisiones, eventos, animaciones, diálogos, tablas, spritesheets, efectos y recursos de UI. Los datos de lógica deben mantenerse separados de los recursos finales de arte.
- **T4.5** Definir cámara 2D cenital/top-down y encuadre. Resolver qué pasa si un mapa original es menor que el área visible o tiene orientación/dimensiones distintas a la ventana horizontal: centrar, usar un fondo ilustrado, extender únicamente decoración no jugable o aplicar otra solución aprobada. No inventar terreno jugable fuera del mapa original. Documentar la decisión en `docs/spec/camera.md`.
- **T4.6** Construir dos variantes de encuadre 2D de una misma escena —cenital más directa y cenital con composición ligeramente elevada mediante el arte— sin construir una perspectiva 3D. Comparar legibilidad de caminos, escala de personajes, lectura de profundidad, cobertura visible, espacios vacíos y similitud con el original.
- **T4.7** 🧑 Revisar las variantes y aprobar la perspectiva, zoom, tamaño de personaje en pantalla, reglas de seguimiento, límites de cámara, encuadre horizontal y orden visual de elementos. Registrar la decisión en `docs/spec/camera.md`; no mantener dos sistemas completos salvo que se apruebe expresamente.
- **T4.8** Crear el primer lote de arte 2D mediante IA y retoque manual: héroe, enemigo, tiles de suelo, obstáculo/elemento de entorno, objeto y efecto de combate. Preparar sprites con transparencia y al menos las animaciones necesarias para la prueba. Revisar a tamaño real de juego, no solo ampliado en el editor.
- **T4.9** Crear `InputMap` con acciones abstractas: mover, atacar, habilidades, objeto rápido, menú, interactuar y cancelar. Implementar soporte inicial para mando y teclado.
- **T4.10** Comparar Godot Compatibility y Mobile con el benchmark 2D cuando se vayan a utilizar luces, shaders, partículas o efectos relevantes. Partir de Compatibility como candidato por compatibilidad amplia; elegir el renderizador definitivo según resultados reproducibles y documentarlo.
- **T4.11** Crear perfiles Bajo, Medio y Alto. Los controles podrán reducir partículas, luces 2D, sombras, efectos, filtros y escala del viewport si se justifica. No degradar el contraste requerido para leer al héroe, enemigos, objetos, proyectiles, hitboxes o HUD.
- **T4.12** Medir el benchmark en 720p/900p, 1080p, 1440p y salida 4K, en los equipos disponibles. Registrar FPS, tiempos de cuadro, memoria, escala de viewport, configuración y posibles artefactos. Revisar también tamaño de texturas, carga de atlas y uso de memoria de imágenes.
- **T4.13** Definir límites iniciales basados en medidas para tamaño de sprites, textura máxima, atlas, cantidad de partículas, luces y elementos decorativos por escena. Usar atlas, reutilización de tiles y descarte de elementos fuera de pantalla cuando las pruebas confirmen que mejoran rendimiento y memoria.

**Criterio de salida:** un mapa se representa correctamente, la UI permanece legible a 1080p, 1440p y salida 4K, la perspectiva 2D y la guía `art/STYLE.md` están aprobadas, y el pipeline IA → retoque manual → spritesheets/tilesheets → Godot se ha validado. En el equipo mínimo de referencia se busca 1080p/60 FPS en perfil bajo; en los equipos recomendados se mide 4K/60 FPS como objetivo, no garantía universal. 🧑 Revisar arte, encuadre, capas, legibilidad y UI.

## 9. Fase 5 · Vertical slice (48 → 58 %)

Construir un tramo jugable representativo desde el mapa de entrenamiento (`m/m/01`) hasta el primer combate completo. Será una prueba técnica y artística, no una reducción del alcance final.

- **T5.1** Implementar el movimiento de acuerdo con el comportamiento original verificado, incluyendo zona muerta configurable para el stick y adaptación a las direcciones de animación disponibles. No alterar la lógica de combate por conveniencia del mando.
- **T5.2** Implementar colisiones 2D a partir de los atributos de tiles, cuerpos/áreas de colisión y transiciones de mapa por portales.
- **T5.3** Implementar un enemigo con IA y ciclo de combate; el ataque del jugador utilizará las hitboxes y ventanas de impacto derivadas de los datos de animación, con daño, muerte y drop.
- **T5.4** Implementar diálogo con fuente recreada y un NPC.
- **T5.5** Inventario mínimo: recoger un objeto de un cofre y usarlo.
- **T5.6** Ejecutar prueba de paridad numérica: con los mismos stats, daño y experiencia coinciden con las fórmulas documentadas en la Fase 3.
- **T5.7** Validar el conjunto mínimo de animaciones 2D del héroe (reposo, movimiento en las direcciones disponibles, ataque, habilidad, recibir daño y muerte) y un conjunto equivalente para el enemigo. Revisar consistencia entre frames, pivote, punto de apoyo, escala, tiempos, transiciones y sincronía con hitboxes. No exigir rig 3D.
- **T5.8** Probar guardado y carga en el tramo vertical, incluido cambio de mapa y salida del juego. No producir grandes cantidades de contenido sobre un estado que no pueda restaurarse.
- **T5.9** Ejecutar el tramo en perfiles Bajo, Medio y Alto; anotar FPS, memoria, artefactos, tiempos de carga y fallos visuales en el equipo de referencia disponible.

**Criterio técnico:** el tramo se juega de principio a fin con mando, guarda y carga su estado de prueba y conserva la paridad de combate aprobada. Los sprites, hitboxes, capas y colisiones funcionan en conjunto. Los perfiles de rendimiento se miden y registran. 🧑 Jugarlo y revisar la sensación de combate, el estilo visual y la claridad del escenario.

### Puerta obligatoria de aprobación antes de la producción masiva

**No se permite iniciar la producción masiva de arte ni de contenido de la Fase 6 hasta que el usuario revise y apruebe explícitamente una única escena jugable integrada en 2D.** Haber completado cada prueba por separado no satisface esta condición: la misma escena debe demostrar conjuntamente que la perspectiva, el estilo artístico, las animaciones, la arquitectura 2D, el combate y el rendimiento funcionan al mismo tiempo. Si falla un punto, se corrige el prototipo y se repite la validación; el agente nunca puede inferir ni otorgar la aprobación.

- **T5.10 · Escena integrada de aprobación:** preparar una escena representativa que incluya el héroe de prueba con arte ya retocado manualmente, al menos un enemigo animado, un fragmento de mapa con tiles definitivos, un elemento superpuesto, un objeto interactivo, combate, colisiones, efectos y HUD. No usar placeholders para componentes visuales esenciales. La perspectiva y el encuadre seleccionados en T4.7 deben ser los definitivos.
- **T5.11 · Validación visual y de arte:** comprobar el estilo 2D ilustrado, la inspiración de alto nivel en Bleaklight Falls sin copiar recursos, la identidad reconocible de Heroes Lore: Zero, la paleta, siluetas, escala, detalle, capas, sombras pintadas, coherencia de animación y legibilidad a tamaño real. Revisar también cómo se ven los assets en el mapa completo y en movimiento, no solo en imágenes aisladas.
- **T5.12 · Validación jugable:** demostrar movimiento, orientación, reposo, desplazamiento, ataque, habilidad, daño recibido y muerte; confirmar la correspondencia entre frames y hitboxes, el ciclo de combate del enemigo, las colisiones, las interacciones y las transiciones incluidas. Las fórmulas y reglas deben coincidir con la referencia o tener una diferencia documentada y aprobada.
- **T5.13 · Validación de rendimiento representativa:** ejecutar la misma escena integrada en perfiles Bajo, Medio y Alto, en equipos de referencia disponibles y en distintas resoluciones de salida. Registrar FPS y tiempos de cuadro, uso de memoria, escala de viewport, tamaño de texturas, atlas, cantidad de partículas/luces y fallos visibles. Probar salida 4K cuando sea posible; no exigir 4K nativo de texturas ni afirmar rendimiento en equipos no probados.
- **T5.14 · Acta y bloqueo de producción:** guardar checklist, capturas o vídeo, resultados, incidencias conocidas y decisión humana en `docs/gates/vertical_slice_approval.md`. Estados permitidos: `pendiente`, `rechazada`, `aprobada con condiciones` o `aprobada`. La producción masiva solo se desbloquea con estado `aprobada`; si queda aprobada con condiciones, solo se permiten las tareas expresamente autorizadas y deben resolverse las condiciones antes de escalar.

**Criterio de salida de la puerta:** el usuario ha jugado o revisado una demostración reproducible de la misma escena integrada, ha comprobado resultados visuales y técnicos y ha registrado su aprobación explícita. La ausencia de respuesta, las pruebas aisladas o una escena con placeholders en componentes esenciales no cuentan como aprobación.

## 10. Fase 6 · Producción de arte y contenido completo (60 → 82 %)

**Dependencia bloqueante:** esta fase no puede empezar en producción masiva hasta que `docs/gates/vertical_slice_approval.md` registre la aprobación explícita definida al final de la Fase 5. Antes de esa aprobación solo se permiten prototipos, mediciones, correcciones y los recursos limitados necesarios para superar la puerta. Si la aprobación se rechaza o queda condicionada, resolver incidencias y repetir el hito antes de producir por regiones.

Trabajar por regiones del juego en el orden de la historia, actualizando `docs/coverage.csv` y manteniendo separado el estado del contenido jugable del estado del arte.

- **T6.1** Completar el cargador de mapas: tiles, capas, colisiones, elementos sobre el jugador, eventos, NPC, portales, cofres y objetos interactivos.
- **T6.2** Completar el motor de eventos y misiones con flags, diálogos y cinemáticas derivados de los datos originales.
- **T6.3** Completar inventario, equipo, tiendas, mejoras, habilidades y efectos de objetos.
- **T6.4** Producir los sprites de todos los tipos de enemigos y sus variantes por familia (`en/0` a `en/5`), con animaciones y datos ligados a la entidad de juego; organizar el trabajo en unidades verificables y commits pequeños.
- **T6.5** Producir jefes con todos los estados, patrones y fases confirmados. Verificar frames de ataque, señales visuales y ventanas de impacto.
- **T6.6** Implementar y verificar minijuegos y extras (`mg1-3`, lotería y otros que aparezcan en la referencia/código).
- **T6.7** Producir e integrar estados alterados, efectos 2D, números de daño, proyectiles y señales visuales. Mantener su lectura clara en perfiles gráficos bajos.
- **T6.8** Aplicar a cada lote de arte el flujo obligatorio: generar alternativas a partir de referencias aprobadas; seleccionar; retocar manualmente; limpiar anatomía, contornos y transparencia; mantener escala y paleta; construir y revisar los frames; exportar spritesheets, tilesheets o atlas; importar a Godot; probar en la perspectiva final; registrar y pedir aprobación. No producir cientos de recursos antes de verificar el primer lote.
- **T6.9** Reutilizar tiles, piezas modulares, paletas, plantillas, puntos de apoyo y convenciones de animación cuando proceda, sin convertir personajes distintos en copias indistinguibles. Asociar cada recurso a su entidad y dato del juego.
- **T6.10** Actualizar `docs/coverage.csv` con estados de arte separados: pendiente, referencia preparada, generado, retoque manual pendiente, retocado, animación pendiente, integrado, QA visual aprobado. Mantener separado este estado de la implementación jugable.
- **T6.11** Después de cada región, ejecutar `tools/verify_region.py`, que carga todos sus mapas en modo headless sin errores; generar una captura de referencia de cada mapa relevante y 🧑 jugar la región.
- **T6.12** Auditar atlas y memoria de texturas por región. Evitar duplicados y texturas innecesariamente grandes; verificar que la compresión no degrade visiblemente las líneas, transparencia o detalles importantes.

**Criterio:** el 100 % de las categorías de contenido originales confirmadas está implementado e integrado, incluida toda la historia, misiones, mapas, NPC, enemigos, jefes, objetos, habilidades, equipo, minijuegos y extras existentes. La historia se completa de principio a fin sin bloqueos. Los recursos visuales cumplen la guía aprobada y son trazables en `art/manifest.csv`; ningún recurso se considera terminado solo por haber sido generado con IA.

## 11. Fase 7 · Audio, HUD y mejoras de calidad de vida (82 → 88 %)

- **T7.1** Música: renderizar los 16 MIDI con FluidSynth y un SoundFont libre de licencia compatible (verificar la licencia), detectar los puntos de bucle y guardar como OGG. Opción para volver al MIDI original.
- **T7.2** Efectos: limpiar los WAV de 8 kHz y 8 bits (remuestreo a 48 kHz, filtrado y normalización con FFmpeg), conservando los originales como alternativa.
- **T7.3** Mezcla por buses (música, efectos, interfaz) con volúmenes en opciones.
- **T7.4** HUD y menús 2D nuevos, escalables hasta 4K y basados en la identidad del diseño original, con navegación completa por foco con D-pad y stick. Priorizar fuentes legibles, iconos coherentes y escalado sin deformación.
- **T7.5** Minimapa generado a partir de los datos del mapa, con niebla de exploración y ampliación a pantalla completa.
- **T7.6** Marcadores de misión: derivarlos de los datos de misiones. Si no alcanza, crear una tabla curada `docs/quest_markers.json`.
- **T7.7** Guardado libre: serializar el estado completo (jugador, flags, inventario, mapas explorados) en `user://saves/` con versión de formato, varias ranuras y autoguardado.

Criterio: se puede guardar y cargar en cualquier punto sin corromper el estado, y el minimapa y los marcadores funcionan en todas las regiones. 🧑 Revisar menús con mando.

## 12. Fase 8 · QA y paridad (88 → 95 %)

- **T8.1** Pruebas unitarias de fórmulas y sistemas contra tablas de referencia.
- **T8.2** Prueba humo automática: recorrer o teletransportarse a todos los mapas en modo headless y comprobar que cargan sin errores, con tiles, capas y colisiones válidas.
- **T8.3** Comparar la planta de cada mapa (muros, caminos, límites, portales, NPC, cofres y elementos interactivos) con capturas de la Fase 1. El arte rediseñado es esperado; la disposición y los eventos deben mantener la paridad.
- **T8.4** Buscar bloqueos de progresión recorriendo la historia con guardados en puntos clave.
- **T8.5** Repetir benchmarks en las zonas más cargadas y con los perfiles Bajo, Medio y Alto. Medir tiempos de cuadro, FPS, memoria, tiempos de carga, tamaño de atlas y picos; corregir cuellos de botella identificados.
- **T8.6** 🧑 Jugar la partida completa con mando y mantener la lista de errores en `docs/bugs.md`; el agente los corrige uno por uno. La aceptación debe incluir capítulos, misiones, jefes, mapas, minijuegos y extras confirmados, no únicamente la ruta principal.
- **T8.7** Verificar la matriz hardware/resolución: equipos mínimos y recomendados disponibles; perfiles bajo/medio/alto; 1080p, 1440p y salida 4K según soporte. Registrar claramente combinaciones no probadas.
- **T8.8** Verificar que todos los elementos de `docs/spec/content_scope.md` tienen evidencia de funcionamiento o una excepción aprobada. La extracción de todos los archivos no demuestra por sí sola cobertura jugable.
- **T8.9** Ejecutar una revisión visual de sprites animados para detectar cambios accidentales de rostro, equipo, colores, proporciones, parpadeos entre frames, halos de transparencia, pivotes incorrectos y costuras entre tiles.

**Criterio:** cero errores bloqueantes, cobertura jugable del 100 % del contenido original confirmado y matriz de rendimiento reproducible con resultados etiquetados como aprobado, fallido o no probado.

## 13. Fase 9 · Pulido y empaquetado (95 → 100 %)

- **T9.1** Menú de opciones: video, audio, control, remapeo de botones, zona muerta, vibración, iconos según el mando (Xbox o PlayStation).
- **T9.2** Exportar a Windows con las plantillas de exportación de Godot.
- **T9.3** Script `setup.bat` que pide el .jar, lo valida por hash y ejecuta el extractor para generar `out/`.
- **T9.4** README con requisitos, instalación y control, y registro de errores a archivo.
- **T9.5** Etiquetar `v1.0` y archivar el .jar y `out/` solo en copia local.

Criterio: partir de una carpeta limpia, ejecutar `setup.bat` y completar toda la historia y el contenido original confirmado. La documentación de requisitos separa con honestidad las prestaciones medidas en equipos modestos y en equipos recomendados; no se anuncia 4K nativo/60 FPS para hardware que no lo haya demostrado.

## Referencias técnicas y visuales

- Godot Engine, introducción oficial al desarrollo 2D: https://docs.godotengine.org/en/stable/tutorials/2d/introduction_to_2d.html
- Godot Engine, animación de sprites 2D: https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html
- Godot Engine, uso de TileSets/TileMapLayer: https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html
- Godot Engine, escalado y resoluciones múltiples: https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html
- Bleaklight Falls (página oficial de Steam): https://store.steampowered.com/app/2820610/Bleaklight_Falls/

Bleaklight Falls se utiliza como referencia externa de vista cenital 2D, composición y atmósfera general. No se copiarán sus assets, sprites, personajes, mapas ni interfaz. La decisión técnica definitiva se valida con prototipos propios del proyecto y el hardware disponible.

## 14. Riesgos y plan B

| Riesgo | Plan B |
| --- | --- |
| Formato `.mpm` más complejo de lo previsto | Dedicar más tiempo a T2.3–T2.4 y apoyarse en el código decompilado; no avanzar con datos incorrectos. |
| Volumen de sprites, animaciones y tiles 2D (cientos de enemigos/variantes y alrededor de 140 mapas, hipótesis que se debe confirmar) | Crear un sistema modular de tiles, atlas y convenciones de animación; priorizar producción por regiones; medir el coste real por sprite/animación/lote antes de escalar. |
| Inconsistencia de la IA entre frames | Usar hojas de modelo, referencias de identidad fijas, prompts controlados y retoque manual por frame; revisar animaciones en bucle y dentro del juego; regenerar o corregir antes de aprobar. |
| Deriva visual entre lotes | Mantener `art/STYLE.md` con ejemplos aprobados, paletas por región, tamaños base y reglas de contorno/sombra; revisar cada lote en el mapa final. |
| Costuras en tiles o elementos demasiado repetitivos | Crear variantes aprobadas, transiciones de terreno y elementos de decoración superpuestos; verificar atlas en muestras grandes del mapa, sin cambiar la distribución jugable. |
| Cobertura de todo el contenido original | Usar inventario y `docs/coverage.csv` como fuente de verdad; herramientas de extracción y producción regional. No declarar versión 1.0 si faltan categorías originales confirmadas. |
| Producción masiva antes de validar estilo, cámara, combate y rendimiento | Puerta bloqueante al final de la Fase 5: una misma escena 2D jugable, evidencia reproducible y aprobación explícita del usuario en `docs/gates/vertical_slice_approval.md`. |
| Rendimiento en equipos modestos y portátiles | Renderer candidato Compatibility, perfiles escalables, atlas eficientes, límites de partículas/luces y perfilado. La compatibilidad de salida 4K no implica texturas 4K ni garantiza 60 FPS en todo hardware. |
| Mapa original vertical y presentación nueva horizontal | Definir una política de encuadre: centrar o adaptar composición sin deformar tiles ni inventar terreno jugable; solicitar aprobación cuando una zona no pueda adaptarse sin cambios visibles. |
| Orden de dibujo incorrecto o sprites ocultos por elementos del entorno | Definir capas y orden Y-sort a partir del punto de apoyo del sprite; usar capas foreground/background para árboles, techos y efectos; crear tests visuales por mapa. |
| Recursos de IA con transparencias, bordes o tamaños inconsistentes | Considerar generación como borrador; establecer validadores de dimensiones, canal alfa, atlas, pivote, recortes y nomenclatura antes de integrar. |
| Licencias de herramientas de IA o referencias | Revisar términos de cada herramienta y registrarlos en `art/manifest.csv`; usar Bleaklight Falls como referencia conceptual de alto nivel, no como fuente de assets. |
| Diferencias por tratarse de un `.jar` modificado | Comparar con una versión limpia si se consigue; etiquetar qué comportamiento procede de la versión inspeccionada. |
| El agente pierde contexto en tareas largas | Mantener `PROGRESS.md`, `OPEN_QUESTIONS.md`, `DECISIONS.md` y commits pequeños al día. |
| Sensación del combate distinta al original | Parámetros de ajuste documentados, reproducción de casos de referencia y revisión humana en el vertical slice y por región. |

## 15. Prompt inicial para el agente

Pega esto al empezar:

```text
Actúas como ingeniero de software senior y responsable de un flujo de producción verificable. Tu objetivo es crear un port fan-made de uso personal de Heroes Lore: Zero para PC con Godot 4, en 2D con vista cenital/top-down y una estética ilustrada moderna inspirada a alto nivel en Bleaklight Falls. No construyas el juego en 3D. La referencia visual no autoriza a copiar sus personajes, escenarios, sprites, UI ni assets. Conserva la identidad de Heroes Lore: Zero y sigue docs/PLAN.md.

La lógica, los mapas, la historia y las reglas deben mantener la fidelidad al juego de referencia. La versión 1.0 debe incluir toda la historia y todo el contenido original confirmado: mapas, NPC, enemigos, jefes, misiones, objetos, habilidades, minijuegos y extras. No recortes el alcance ni declares terminado el proyecto con contenido original pendiente.

El arte nuevo se genera con IA y lo retoca manualmente el usuario. Trata las generaciones como borradores, no como assets finales. Organiza fuentes, registra prompts/herramientas/licencias disponibles y prepara imágenes para retoque manual, spritesheets, tilesheets y atlas. Comprueba transparencia, bordes, paleta, silueta, escala, pivotes, continuidad de frames y lectura a tamaño real de juego. Mantén la dirección visual aprobada en art/STYLE.md y solicita aprobación humana en los puntos marcados.

El juego debe funcionar también en PC modestos y portátiles. Incluye perfiles Bajo, Medio y Alto, optimiza atlas y texturas, mide el uso de memoria y ejecuta benchmarks antes de aprobar prestaciones. La salida 4K es una opción de presentación y no significa exigir assets 4K ni prometer 60 FPS en todos los equipos. Registra objetivos y resultados por cada equipo de referencia, sin inventar garantías.

Reglas: trabaja fase por fase y tarea por tarea, un commit por tarea; verifica con comandos antes de avanzar; nunca asumas formatos (deduce del código decompilado); valida la perspectiva 2D con un prototipo; conserva datos, colisiones y eventos en formatos estructurados; actualiza docs/PROGRESS.md, docs/OPEN_QUESTIONS.md y docs/DECISIONS.md; registra cada recurso en art/manifest.csv; mantén art/STYLE.md, docs/spec/content_scope.md y docs/spec/performance.md actualizados; detente en los puntos 🧑 para revisión del usuario.

No inicies la producción masiva de la Fase 6 hasta completar una escena 2D integrada y obtener la aprobación explícita del usuario indicada en docs/gates/vertical_slice_approval.md. La misma escena debe probar arte final de muestra, perspectiva/cámara, sprites animados, capas, colisiones, combate, UI y rendimiento. No infieras ni otorgues esa aprobación por tu cuenta.

Empieza leyendo docs/PLAN.md y ejecuta la Fase 0.
```
