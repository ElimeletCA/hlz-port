# OPEN_QUESTIONS — Heroes Lore: Zero Port

Lista de dudas sin resolver. Cada entrada incluye fase, tarea, descripción y estado.

| ID | Fase | Tarea | Pregunta | Estado |
|----|------|-------|----------|--------|
| OQ-001 | F2 | T2.4 | ¿Estructura exacta del formato `.mpm`? | ✅ resuelta — Chunks PNG modulares: paleta compartida (`PLTE` + `tRNS`) en Bloque C y geometría (`IHDR` + `IDAT`) en sub-bloques. Ver `docs/formats/mpm.md`. |
| OQ-002 | F2 | T2.4 | ¿Función de los 141 archivos `mmi/` de 70 bytes? | ✅ resuelta — Coordenadas de objetivo (X, Y) para 35 etapas de misión por cada mapa. Ver `docs/formats/mmi.md`. |
| OQ-003 | F2 | T2.4 | ¿Estructura y contenido de los `.tdf`? | ✅ resuelta — Tabla de textos: 1 byte con total de entradas, seguido de registros con longitud (uint16_be) y cadena UTF-8/latin-1. Ver `docs/formats/tdf.md`. |
| OQ-004 | F1 | T1.4 | ¿Cuántos ticks por segundo ejecuta la lógica original (`TICK_HZ`)? | ✅ resuelta — Bucle principal en `rpg/e.java` usa array `{6, 10, 14, 18}` Hz con índice 2 por defecto: 14 ticks/segundo (~71 ms). |
| OQ-005 | F0 | T0.1 | FluidSynth: ¿está instalado? | ✅ resuelta — FluidSynth 2.6.1, `tools/fluidsynth/fluidsynth-v2.6.1-win10-x64-cpp11/bin/fluidsynth.exe` |
| OQ-006 | F0 | T0.1 | Vineflower o CFR: ¿está instalado? | ✅ resuelta — Vineflower 1.12.0, `tools/vineflower-1.12.0.jar` |
| OQ-007 | F0 | T0.1 | Emulador J2ME (FreeJ2ME-Plus): ¿instalado? | ✅ resuelta — FreeJ2ME-Plus nightly, `tools/freej2me-plus/freej2me_plus.jar` |
| OQ-008 | F0 | T0.1 | Editor de imágenes 2D (Krita/GIMP): ¿instalado? | ✅ resuelta — Krita 5.3.4.1 (instalación en curso via winget) |
| OQ-009 | F4 | T4.5 | ¿Cómo adaptar los mapas originales verticales 360×640 a presentación horizontal sin inventar terreno jugable? Pendiente de decisión. | abierta |
| OQ-010 | F2 | T2.3 | La versión del .jar es modificada (v4.4.45, español). ¿Existen diferencias de contenido respecto a la versión limpia? Verificar si se consigue la versión original. | abierta |
