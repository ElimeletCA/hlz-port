# Especificación de formato binario: .m (Map Data File)

Documento técnico deducido a partir de la desofuscación de `rpg/c.java` (líneas 370–383) y `e.java` (líneas 371–520).

---

## 1. Nomenclatura y ubicación

Los mapas originales del juego se dividen en dos carpetas dentro del JAR:
- Mapas 0 a 99: `/m/m/00.m` a `/m/m/99.m`
- Mapas 100+: `/m/m2/<letra><digito>.m` (ej. 100 -> `a0.m`, 101 -> `a1.m`, 110 -> `b0.m`...)

---

## 2. Dimensiones y resolución de casillas (tiles)

- Cada tile o casilla mide **16 × 16 píxeles** (`c << 4` y `d << 4` en `e.java`).

---

## 3. Estructura binaria de un archivo `.m`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `map_flags` | `uint8` | Banderas de entorno del mapa (interior/exterior, iluminación). |
| `music_id` | `uint8` | ID de música de fondo asociada (índice en `/snd/b/`). |
| `weather_id`| `uint8` | Efecto atmosférico o clima. |
| `tileset_refs` | `2 x (uint8 len + bytes)` | Referencias a los tilesets u objetos de escenario base. |
| `tile_def_count` | `uint8` | Cantidad de definiciones de tiles de mapa (`/m/obX.mpm`). |
| `tile_defs` | `bytes[tile_def_count]` | Mapeo de índices de tiles a gráficos en `/m/obX.mpm`. |
| `width` | `uint8` | Ancho del mapa en número de casillas (tiles). |
| `height` | `uint8` | Alto del mapa en número de casillas (tiles). |
| `layer_ground` | `bytes[width * height]` | Índices de tile para la capa inferior de suelo (fondo). |
| `layer_overlay` | `bytes[width * height]` | Índices de tile para la capa superior / colisión. |
| `objects_count` | `uint8` | Cantidad de entidades interactivas (NPCs / cofres). |
| `objects` | `objects_count * 5 bytes` | Registros de entidad: `[uint8 id, int16_le x, int16_le y]`. |
| `decor_count` | `uint8` | Cantidad de decoraciones superpuestas. |
| `decorations` | `decor_count * 5 bytes` | Registros: `[uint8 id, int16_le x, int16_le y]`. |
| `spawns_count` | `uint8` | Cantidad de puntos de aparición o triggers adicionales. |
| `spawns` | `spawns_count * 5 bytes` | Registros: `[uint8 id, int16_le x, int16_le y]`. |
| `enemy_count` | `uint8` | Cantidad de enemigos que patrullan el mapa. |
| `enemies` | `bytes[enemy_count]` | IDs de enemigos presentes (referencia a `/en/`). |
| `portals_count` | `uint8` | Cantidad de salidas / portales de teletransporte a otros mapas. |
| `portals` | variable | Coordenadas de entrada, mapa de destino y coordenadas de llegada. |
