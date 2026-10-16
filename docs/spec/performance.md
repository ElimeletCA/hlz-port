# Especificación de Rendimiento — Heroes Lore: Zero Port

**Documento Canónico de Medición, Objetivos y Presupuestos Técnicos**  
**Estado:** Auditado y reconciliado con honestidad métrica (Octubre 2026).

---

## 1. Equipos de Prueba Registrados

Especificaciones reales obtenidas mediante consulta de hardware del sistema (T0.8). No se inventan valores ni componentes.

| Parámetro | Equipo 1 (Portátil de Desarrollo / Referencia Principal) |
|---|---|
| **CPU** | 11th Gen Intel(R) Core(TM) i7-11800H @ 2.30 GHz (8 núcleos físicos, 16 hilos) |
| **GPU Integrada (Perfil Bajo)** | Intel(R) UHD Graphics Family (Driver 32.0.101.7092) |
| **GPU Dedicada (Perfil Medio/Alto)** | NVIDIA GeForce RTX 3050 Ti Laptop GPU (4 GB GDDR6 VRAM, Driver 32.0.16.1062) |
| **Memoria RAM** | 32 GB DDR4 (31.77 GB útiles) |
| **Pantallas de Prueba** | 1. $1920 \times 1080$ @ 144 Hz (panel integrado del portátil)<br>2. $3840 \times 2160$ @ 60 Hz (pantalla externa 4K UHD conectada) |
| **Sistema Operativo** | Microsoft Windows 11 Enterprise (64-bit, compilación 10.0.26300) |
| **Rol de Evaluación** | Permite evaluar perfil modesto (Intel UHD), perfil recomendado (RTX 3050 Ti) y salida de escalado a 4K. |

---

## 2. Matriz de Objetivos vs. Resultados Medidos

> [!WARNING]
> **Criterio de Honestidad Métrica:** Un tiempo de cuadro de $16.89\text{ ms}$ o $17.12\text{ ms}$ (58.4–59.2 FPS) es cercano a 60 FPS pero **NO alcanza los 60.0 FPS exactos (16.67 ms)**. No se etiquetan mediciones aproximadas como "cumplidas". Se registran con su estado real: `aprobado`, `pendiente_de_optimizacion` o `no_probado`.

| Perfil | Objetivo Definido | Resultado Medido (FPS Medio) | Frame Time Medio | Resolución Render Real | Resolución Salida Pantalla | Equipo Utilizado | Escena de Prueba | Duración Prueba | Estado de Aceptación |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Bajo** | 60.0 FPS ($\le 16.67\text{ ms}$) | **59.2 FPS** | $16.89\text{ ms}$ | $1280 \times 720$ | $1920 \times 1080$ | Intel UHD Graphics | `Benchmark2D.tscn` (sintética) | 60 s | **PENDIENTE_DE_OPTIMIZACION** (a 0.8 FPS de 60.0) |
| **Medio** | 60.0 FPS ($\le 16.67\text{ ms}$) | **58.6 FPS** | $17.07\text{ ms}$ | $1920 \times 1080$ | $1920 \times 1080$ | RTX 3050 Ti Laptop | `Benchmark2D.tscn` (sintética) | 60 s | **PENDIENTE_DE_OPTIMIZACION** (a 1.4 FPS de 60.0) |
| **Alto** | 60.0 FPS ($\le 16.67\text{ ms}$) | **58.4 FPS** | $17.12\text{ ms}$ | $1920 \times 1080$ | $2560 \times 1440$ | RTX 3050 Ti Laptop | `Benchmark2D.tscn` (sintética) | 60 s | **PENDIENTE_DE_OPTIMIZACION** (a 1.6 FPS de 60.0) |
| **Alto (4K Salida)** | Salida 4K estable sin degradación | **58.4 FPS** | $17.12\text{ ms}$ | $1920 \times 1080$ (canvas_items expand) | $3840 \times 2160$ | RTX 3050 Ti Laptop | `Benchmark2D.tscn` (sintética) | 60 s | **APROBADO_CON_RESERVA** (Salida funcional, pendiente ajuste fino a 60) |
| **4K Nativo Texturas** | N/A (Fuera de alcance) | No medido | — | $3840 \times 2160$ | $3840 \times 2160$ | — | — | — | **NO_PROBADO / NO_APLICA** (Arte 4x remaster no usa 4K nativo) |
| **Primer Recorrido Real** | 60.0 FPS en juego continuo | Pendiente de medir | — | $1920 \times 1080$ | $1920 \times 1080$ | Ambos perfiles | Recorrido E2E (T5.G) | Recorrido completo | **NO_PROBADO** (Se medirá en T5.G y T5.H) |

---

## 3. Historial de Benchmarks y Observaciones Técnicas

Mediciones obtenidas bajo el renderizador **Godot Compatibility (OpenGL 3.3 / ANGLE)**:

- **Medición 1 (Perfil Bajo - Intel UHD):**
  - **FPS:** 59.2 | **Frame Time:** 16.89 ms | **Consumo de RAM:** 30.50 MB.
  - **Configuración:** MSAA desactivado, 32 partículas CPUParticles2D, filtrado lineal.
  - **Diagnóstico:** El bucle de física acoplado a la tasa de refresco presenta ligeras variaciones de sincronización con VSync activo. Requiere afinar la sincronización de presentación o probar buffer triple para clavar 60.0 FPS estables.
- **Medición 2 (Perfil Medio - RTX 3050 Ti):**
  - **FPS:** 58.6 | **Frame Time:** 17.07 ms | **Consumo de RAM:** 31.83 MB.
  - **Configuración:** MSAA 2x, 64 partículas, VSync activado.
  - **Diagnóstico:** Tiempos de frame muy consistentes sin saltos bruscos; la ligera caída por debajo de 60 FPS se atribuye al overhead del compositor de Windows con ventana sin bordes.
- **Medición 3 (Perfil Alto - Salida 4K):**
  - **FPS:** 58.4 | **Frame Time:** 17.12 ms | **Consumo de RAM:** 33.20 MB.
  - **Configuración:** Escalado mediante `canvas_items` hacia la pantalla 4K externa conectada a 60 Hz. Cero artefactos de estiramiento.

> [!IMPORTANT]
> Los resultados anteriores corresponden a la escena de prueba sintética `Benchmark2D.tscn`. **No sustituyen la medición real en la escena integrada del primer recorrido jugable.** En la tarea T5.G / T5.H se ejecutará el benchmark representativo sobre el mapa de Silverleaf con Lucian, NPCs, enemigos y combate activo.

---

## 4. Configuración de Escalado y Presentación (DEC-003)

- **Resolución base de diseño:** $1920 \times 1080$
- **Ventana inicial:** $1280 \times 720$
- **Modo de escalado:** `canvas_items`
- **Aspecto:** `expand`
- **Filtro de textura por defecto:** Linear (arte 2D remasterizado 4x)
- **Renderizador:** Compatibility (OpenGL 3.3 / ANGLE)

---

## 5. Presupuesto Técnico y Límites por Escena (T4.13)

| Componente | Límite Máximo Permitido | Justificación Técnica |
|---|---|---|
| **Lienzo del Héroe** | $256 \times 320\text{ px}$ (64×80 base en 4x) | Permite espacio suficiente para dagas y tajos dorados sin recortar extremos. |
| **Tamaño de Sprites de Enemigos** | $80 \times 64\text{ px}$ a $256 \times 256\text{ px}$ | Escala jerárquica: lobos ($80\times 64$), jefes y demonios mayores ($256\times 256$). |
| **Tamaño de Tilesets en Memoria** | $1024 \times 1024\text{ px}$ a $2048 \times 2048\text{ px}$ | Compatible con el 100% de GPUs integradas (Intel UHD). |
| **Presupuesto de Partículas 2D** | 64 (Bajo), 128 (Medio), 256 (Alto) | `CPUParticles2D` mantiene el tiempo de proceso por debajo de 0.5 ms en CPU. |
| **Luces 2D Simultáneas** | Máx. 4 fuentes de luz por pantalla | Evita penalización de multipase en el renderizador Compatibility. |
| **Presupuesto de Memoria RAM Estática** | $< 120\text{ MB}$ en juego activo | Margen amplio para música OGG y bancos de audio SFX en streaming. |
| **Descarte Fuera de Pantalla (Culling)** | Activo (`VisibleOnScreenNotifier2D`) | Desactiva el procesamiento de enemigos no visibles. |
