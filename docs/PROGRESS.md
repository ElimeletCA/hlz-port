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

