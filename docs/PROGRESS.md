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
