# Especificación de formato binario: .tdf (Text Data File)

Documento técnico deducido a partir de la desofuscación de `cx.java` y verificado contra los 31 archivos `.tdf` del JAR de Heroes Lore: Zero.

---

## 1. Propósito

El formato `.tdf` almacena tablas de cadenas de texto localizadas (diálogos, nombres de menús, descripciones de misiones, créditos, interfaz).

---

## 2. Estructura binaria

Todos los enteros de 16 bits están codificados en orden **Big-Endian** (red).

| Desplazamiento | Tipo | Campo | Descripción |
|----------------|------|-------|-------------|
| `0x00` | `uint8` | `entry_count` | Número total de entradas de texto contenidas en el archivo (0–255). |

A continuación se suceden secuencialmente `entry_count` registros:

### Registro de entrada de texto (repetido `entry_count` veces)

| Desplazamiento relativo | Tipo | Campo | Descripción |
|-------------------------|------|-------|-------------|
| `+0` | `uint16_be` | `length` | Longitud en bytes de la cadena de texto subsiguiente. |
| `+2` | `bytes[length]`| `text_bytes` | Caracteres de la cadena codificados en UTF-8 (o ISO-8859-1 en caracteres especiales). |

---

## 3. Ejemplo de parseo en Python

```python
import struct

def parse_tdf(data: bytes) -> list[str]:
    entry_count = data[0]
    entries = []
    offset = 1
    for _ in range(entry_count):
        length = struct.unpack(">H", data[offset:offset+2])[0]
        offset += 2
        text_raw = data[offset:offset+length]
        offset += length
        try:
            text = text_raw.decode("utf-8")
        except UnicodeDecodeError:
            text = text_raw.decode("latin-1")
        entries.append(text)
    return entries
```

---

## 4. Archivos conocidos en el JAR

31 archivos ubicados principalmente en el directorio `t/`:
- `t/a.tdf`: Información del juego y créditos
- `t/com.tdf`: Textos comunes de interfaz (Cargando, Sí, No...)
- `t/h.tdf`: Ayuda y tutoriales (Controles básicos, Personaje, Profesión...)
- `t/c.tdf`, `t/gm.tdf`...: Diálogos y cadenas de eventos de la historia
