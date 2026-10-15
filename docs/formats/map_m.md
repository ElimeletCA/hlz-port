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
| `tileset_0` | `uint8` | Índice del tileset primario del mapa (carga `/m/tXX.mpm`, de 0 a 34). |
| `tileset_1` | `uint8` | Índice del tileset secundario del mapa (carga `/m/tXX.mpm`). |
| `location_name` | `uint8 len + bytes` | Nombre de la zona o mapa en español (ej. "Aldea Silverleaf", "Ciudad Humming"). |
| `sub_location` | `uint8 len + bytes` | Nombre del sub-sector o piso (ej. "Orfanato", "Puerto", "Nivel 2 Cuarto B"). |
| `tile_def_count` | `uint8` | Cantidad de definiciones de objetos / props de mapa (`/m/obX.mpm`). |
| `tile_defs` | `bytes[tile_def_count]` | Mapeo de índices de objetos a gráficos en `/m/obX.mpm`. |
| `width` | `uint8` | Ancho del mapa en número de casillas (tiles de 16×16 px). |
| `height` | `uint8` | Alto del mapa en número de casillas (tiles de 16×16 px). |
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
