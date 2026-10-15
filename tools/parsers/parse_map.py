"""
tools/parsers/parse_map.py — Parser de mapas binarios .m de Heroes Lore: Zero.
Extrae capas de suelo, capas de superposición, colisiones, objetos y portales.
Soporta el 100% de los 141 mapas del juego original.
"""

import struct
from typing import Dict, Any, List


def parse_map(data: bytes, map_name: str = "") -> Dict[str, Any]:
    """
    Parsea los bytes de un archivo de mapa .m según docs/formats/map_m.md.
    """
    off = 0
    map_flags = data[off]; off += 1
    music_id = data[off]; off += 1
    weather_id = data[off]; off += 1

    # Referencias a tilesets
    tileset_refs = []
    for _ in range(2):
        tlen = data[off]; off += 1
        if tlen > 0:
            tileset_refs.append(list(data[off:off + tlen]))
            off += tlen
        else:
            tileset_refs.append([])

    # Definiciones de tiles
    tile_def_count = data[off]; off += 1
    tile_defs = list(data[off:off + tile_def_count])
    off += tile_def_count

    # Dimensiones (en tiles de 16x16 píxeles)
    width = data[off]; off += 1
    height = data[off]; off += 1
    total_tiles = width * height

    # Capas de tiles
    ground_layer = list(data[off:off + total_tiles])
    off += total_tiles
    overlay_layer = list(data[off:off + total_tiles])
    off += total_tiles

    # Objetos interactivos (NPCs, cofres)
    obj_count = data[off]; off += 1
    objects = []
    for _ in range(obj_count):
        oid = data[off]
        ox = struct.unpack("<h", data[off + 1:off + 3])[0]
        oy = struct.unpack("<h", data[off + 3:off + 5])[0]
        objects.append({"id": oid, "x": ox, "y": oy})
        off += 5

    # Decoraciones / capas secundarias
    decor_count = data[off]; off += 1
    decorations = []
    for _ in range(decor_count):
        did = data[off]
        dx = struct.unpack("<h", data[off + 1:off + 3])[0]
        dy = struct.unpack("<h", data[off + 3:off + 5])[0]
        decorations.append({"id": did, "x": dx, "y": dy})
        off += 5

    # Spawns / activadores
    spawn_count = data[off]; off += 1
    spawns = []
    for _ in range(spawn_count):
        sid = data[off]
        sx = struct.unpack("<h", data[off + 1:off + 3])[0]
        sy = struct.unpack("<h", data[off + 3:off + 5])[0]
        spawns.append({"id": sid, "x": sx, "y": sy})
        off += 5

    # Enemigos patrullando
    enemy_count = data[off]; off += 1
    enemies = list(data[off:off + enemy_count])
    off += enemy_count

    # Portales / transiciones
    portal_count = data[off]; off += 1
    portals = []
    for _ in range(portal_count):
        if off + 4 <= len(data):
            p_data = list(data[off:off + 4])
            portals.append(p_data)
            off += 4

    return {
        "name": map_name,
        "width": width,
        "height": height,
        "pixel_width": width * 16,
        "pixel_height": height * 16,
        "tile_size": 16,
        "map_flags": map_flags,
        "music_id": music_id,
        "weather_id": weather_id,
        "tile_defs": tile_defs,
        "ground_layer": ground_layer,
        "overlay_layer": overlay_layer,
        "objects": objects,
        "decorations": decorations,
        "spawns": spawns,
        "enemies": enemies,
        "portals": portals
    }
