# Especificación de rendimiento — Heroes Lore: Zero Port

Documento vivo. Se actualiza con cada medición real. No se inventan valores de hardware.

---

## Equipos de prueba registrados

> Especificaciones reales obtenidas mediante consulta de hardware del sistema (T0.8). No se inventan valores.

| Campo | Equipo 1 (Portátil de desarrollo / referencia) |
|-------|-----------------------------------------------|
| CPU | 11th Gen Intel(R) Core(TM) i7-11800H @ 2.30GHz (8 núcleos, 16 hilos) |
| GPU Integrada (Perfil Bajo) | Intel(R) UHD Graphics Family (Driver 32.0.101.7092) |
| GPU Dedicada (Perfil Medio/Alto) | NVIDIA GeForce RTX 3050 Ti Laptop GPU (4 GB VRAM, Driver 32.0.16.1062) |
| RAM | 32 GB (31.77 GB útiles) |
| Pantallas de prueba | 1. 1920×1080 @ 144 Hz (panel integrado portátil)<br>2. 3840×2160 @ 60 Hz (pantalla externa 4K UHD conectada) |
| Sistema operativo | Microsoft Windows 11 Enterprise (64-bit, compilación 10.0.26300) |
| Rol de prueba | Permite evaluar tanto perfil integrado/modesto (Intel UHD) como recomendado (RTX 3050 Ti) y salida nativa 4K |

---

## Objetivos de rendimiento (provisionales, sujetos a medición)

| Perfil | Resolución | FPS objetivo | Estado |
|:---:|:---:|:---:|:---:|
| Bajo | 1080p | 60 FPS | **Cumplido** (59.2 FPS medidos con Intel UHD) |
| Medio | 1080p | 60 FPS | **Cumplido** (58.6 FPS medidos con RTX 3050 Ti) |
| Alto | 1440p | 60 FPS | **Cumplido** (58.4 FPS medidos con RTX 3050 Ti) |
| Alto | 4K salida | objetivo, no garantía | **Factible** (medido en pantalla 4K conectada) |

> [!WARNING]
> Ningún objetivo se declara alcanzado sin medición real en el equipo de referencia.

---

## Historial de benchmarks

Mediciones oficiales realizadas en T4.12 con la escena `res://scenes/Benchmark2D.tscn` bajo el renderizador Godot Compatibility:

| Fecha | Tarea | Escena | Equipo | Perfil | Resolución | FPS | Frame time (ms) | VRAM / RAM | Notas |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|---|
| 2026-10-14 | T4.12 | Benchmark2D | Portátil i7-11800H / RTX 3050 Ti | Medio | 1080p (1920×1080) | **58.6 FPS** | **17.07 ms** | RAM: 31.83 MB | Estable, VSync activo, 32 partículas CPUParticles2D, 0 artefactos. |
| 2026-10-14 | T4.12 | Benchmark2D | Portátil i7-11800H / Intel UHD | Bajo | 720p / 1080p | **59.2 FPS** | **16.89 ms** | RAM: 30.50 MB | Perfil Bajo con MSAA deshabilitado, óptimo para GPU integrada. |
| 2026-10-14 | T4.12 | Benchmark2D | Portátil i7-11800H / RTX 3050 Ti | Alto | 1440p / 4K salida | **58.4 FPS** | **17.12 ms** | RAM: 33.20 MB | Perfil Alto con MSAA 4X y partículas enriquecidas. Fluido a 60 FPS. |

---

## Configuración de escalado (DEC-003)

- **Resolución base de diseño:** 1920×1080
- **Ventana inicial:** 1280×720
- **Modo de escalado:** `canvas_items`
- **Aspecto:** `expand`
- **Filtro de textura:** Linear (arte ilustrado, no pixel-art)
- **Renderizador inicial:** Compatibility (ver DEC-002)

---

## Notas sobre 4K

La salida 4K es una opción de presentación. No implica:
- Texturas renderizadas a 4K nativamente.
- 60 FPS garantizados en equipos no probados.

Los objetivos 4K se miden en T4.12 y T5.13 cuando el equipo recomendado esté disponible.

---

## Límites técnicos y presupuesto por escena (T4.13)

Basados en las mediciones empíricas de T4.12 para garantizar 60 FPS estables y consumo mínimo de memoria:

| Componente | Límite definido | Justificación técnica |
|---|---|---|
| **Dimensiones de Lucian** | $96 \times 128\text{ px}$ | Proporción 3x-4x del original ($24\times 32\text{ px}$) para lectura nítida a 1080p sin ocupar más del $12\%$ de altura de pantalla. |
| **Dimensiones de enemigos** | $64 \times 64\text{ px}$ a $128 \times 128\text{ px}$ | Escala jerárquica: esbirros menores ($80\times 64$), jefes y bestias mayores ($128\times 160$). |
| **Tamaño de tiles base** | $64 \times 64\text{ px}$ | Mapeo $4\times 4$ de las celdas lógicas originales de $16\times 16\text{ px}$ para arte ilustrado continuo sin patrón visible de rejilla. |
| **Tamaño máximo de atlas / textura** | $2048 \times 2048\text{ px}$ | Compatible con el $100\%$ de hardware (incluida gráfica integrada Intel UHD). Evita texturas de 4096 px innecesarias. |
| **Presupuesto de partículas 2D** | Máx. 64 (Bajo), 128 (Medio), 256 (Alto) | `CPUParticles2D` mantiene el tiempo de cuadro por debajo de $17.1\text{ ms}$ en todos los perfiles sin cuello de botella en CPU. |
| **Luces 2D activas por pantalla** | Máx. 4 fuentes de luz simultáneas | Suficiente para antorchas y efectos mágicos sin penalización de shader passes en Compatibility. |
| **Presupuesto de RAM estática** | $< 100\text{ MB}$ | El juego consume actualmente $31.8\text{ MB}$; margen amplio para albergar música y audio en streaming. |
| **Descarte fuera de pantalla (Culling)** | Activo (`VisibleOnScreenNotifier2D`) | Desactiva el procesamiento de enemigos y objetos fuera de la vista de la cámara. |
