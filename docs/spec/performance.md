# Especificación de rendimiento — Heroes Lore: Zero Port

Documento vivo. Se actualiza con cada medición real. No se inventan valores de hardware.

---

## Equipos de prueba registrados

> Completar con especificaciones reales del equipo disponible. Ver T0.8.

| Campo | Equipo 1 (disponible) | Equipo 2 |
|-------|----------------------|----------|
| CPU | *pendiente T0.8* | — |
| GPU / Gráfica integrada | *pendiente T0.8* | — |
| RAM | *pendiente T0.8* | — |
| Resolución de pantalla | *pendiente T0.8* | — |
| Sistema operativo | Windows | — |
| Rol provisional | Mínimo de referencia | — |

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
