# Especificación de formato binario: mmi (Map Mission Indicators)

Documento técnico deducido a partir de la desofuscación de `e.java` (líneas 142–190) y verificado contra los 141 archivos `mmi/` del JAR de Heroes Lore: Zero.

---

## 1. Propósito

Los archivos dentro del directorio `mmi/` contienen las coordenadas objetivo (X, Y en casillas/tiles) para los marcadores de misión y flechas guía en el minimapa por cada fase de la historia principal.

Cada archivo se nombra con el identificador numérico de su mapa correspondiente:
`mmi/0`, `mmi/1`, `mmi/2`, ..., `mmi/140` (141 mapas en total).

---

## 2. Estructura binaria

Todos los archivos `mmi/` tienen un tamaño fijo e invariable de exactamente **70 bytes**.

Contienen 35 pares de coordenadas correspondientes a las 35 etapas principales de misión evaluadas en `dq.a()`:

| Byte | Tipo | Campo | Descripción |
|------|------|-------|-------------|
| `0x00` | `uint8` | `target_x_stage1` | Coordenada X (tile) objetivo para la etapa de misión 1 (`0xFF` = sin marcador). |
| `0x01` | `uint8` | `target_y_stage1` | Coordenada Y (tile) objetivo para la etapa de misión 1 (`0xFF` = sin marcador). |
| `0x02` | `uint8` | `target_x_stage2` | Coordenada X (tile) para la etapa de misión 2. |
| `0x03` | `uint8` | `target_y_stage2` | Coordenada Y (tile) para la etapa de misión 2. |
| ... | ... | ... | ... |
| `0x44` | `uint8` | `target_x_stage35`| Coordenada X (tile) para la etapa de misión 35. |
| `0x45` | `uint8` | `target_y_stage35`| Coordenada Y (tile) para la etapa de misión 35. |

### Valores especiales
- `(0xFF, 0xFF)` (o `(-1, -1)` en Java con signo): Indica que en esa etapa de misión no hay ningún objetivo ubicado en este mapa.
- Excepciones hardcodeadas en `e.java`:
  - Si el mapa es `8` y la bandera secundaria está activa: X=0, Y=0.
  - Si el mapa es `10` y la bandera secundaria está activa: X=5, Y=10.

---

## 3. Ejemplo de parseo en Python

```python
def parse_mmi(data: bytes) -> dict[int, tuple[int, int] | None]:
    assert len(data) == 70, f"Tamaño inválido: {len(data)} (se esperaban 70 bytes)"
    markers = {}
    for stage in range(1, 36):
        x = data[(stage - 1) * 2]
        y = data[(stage - 1) * 2 + 1]
        if x == 255 and y == 255:
            markers[stage] = None
        else:
            markers[stage] = (x, y)
    return markers
```
