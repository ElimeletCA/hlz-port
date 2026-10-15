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
|--------|-----------|--------------|--------|
| Bajo | 1080p | 60 FPS | no medido |
| Medio | 1080p | 60 FPS | no medido |
| Alto | 1440p | 60 FPS | no medido |
| Alto | 4K salida | objetivo, no garantía | no medido |

> [!WARNING]
> Ningún objetivo se declara alcanzado sin medición real en el equipo de referencia.

---

## Historial de benchmarks

Pendiente. Las mediciones se realizan en T4.12 y T5.13 con la escena de benchmark definida en T0.9.

| Fecha | Tarea | Escena | Equipo | Perfil | Resolución | FPS | Frame time (ms) | VRAM | RAM | Notas |
|-------|-------|--------|--------|--------|-----------|-----|----------------|------|-----|-------|
| — | — | — | — | — | — | — | — | — | — | — |

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
