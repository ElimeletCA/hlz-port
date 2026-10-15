"""
tools/render_maps.py — Renderizador de mapas 2D originales de Heroes Lore: Zero.
Reconstruye mapas a partir de capas de tiles y tilesets en out/sprites/m/tXX/.
Genera renders PNG en out/renders/ para verificación visual con el emulador (T2.7).
"""

import json
import os
import sys
from pathlib import Path
from PIL import Image, ImageDraw

REPO_ROOT = Path(__file__).resolve().parent.parent
MAPS_DIR = REPO_ROOT / "out" / "maps"
SPRITES_DIR = REPO_ROOT / "out" / "sprites"
RENDERS_DIR = REPO_ROOT / "out" / "renders"


def load_tileset(ts_id: int):
    """Carga los tiles individuales de un tileset tXX en memoria."""
    ts_folder = SPRITES_DIR / "m" / f"t{ts_id:02d}"
    if not ts_folder.exists():
        return []
    
    # Los frames se ordenan por nombre frame_000.png, frame_001.png...
    frames = sorted(ts_folder.glob("*.png"))
    imgs = []
    for f in frames:
        try:
            imgs.append(Image.open(f).convert("RGBA"))
        except Exception:
            pass
    return imgs


def render_map(map_path: Path, output_path: Path = None, draw_collision: bool = False) -> Path:
    """Renderiza un mapa completo a PNG."""
    with open(map_path, "r", encoding="utf-8") as f:
        m = json.load(f)

    ts0_id = m.get("tileset_0", 0)
    ts1_id = m.get("tileset_1", 255)
    width = m["width"]
    height = m["height"]
    ground = m.get("ground_layer", [])
    overlay = m.get("overlay_layer", [])
    loc_name = m.get("location_name", "")
    sub_loc = m.get("sub_location", "")

    # Cargar tilesets
    tiles_0 = load_tileset(ts0_id)
    tiles_1 = load_tileset(ts1_id) if ts1_id != 255 else []
    all_tiles = tiles_0 + tiles_1
    split = len(tiles_0)

    # Crear lienzo
    img = Image.new("RGBA", (width * 16, height * 16), (16, 20, 24, 255))

    # 1. Capa de suelo
    for y in range(height):
        for x in range(width):
            idx = y * width + x
            if idx >= len(ground):
                continue
            val = ground[idx]
            offset = split if (val & 128) != 0 else 0
            tile_idx = offset + (val & 127) - 1
            if 0 <= tile_idx < len(all_tiles):
                tile_img = all_tiles[tile_idx]
                img.paste(tile_img, (x * 16, y * 16), tile_img)

    # 2. Capa de superposición / colisión
    for y in range(height):
        for x in range(width):
            idx = y * width + x
            if idx >= len(overlay):
                continue
            val = overlay[idx]
            tile_val = val & 63
            if tile_val > 0:
                offset = split if (val & 128) != 0 else 0
                tile_idx = offset + tile_val - 1
                if 0 <= tile_idx < len(all_tiles):
                    tile_img = all_tiles[tile_idx]
                    img.paste(tile_img, (x * 16, y * 16), tile_img)

    # 3. Capa de colisión opcional (rojo semi-transparente)
    if draw_collision:
        overlay_draw = Image.new("RGBA", img.size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay_draw)
        for y in range(height):
            for x in range(width):
                idx = y * width + x
                if idx < len(overlay):
                    val = overlay[idx]
                    if (val & 128) != 0:
                        # Bloqueado sólido
                        draw.rectangle([x * 16, y * 16, (x + 1) * 16 - 1, (y + 1) * 16 - 1], fill=(255, 0, 0, 70))
        img = Image.alpha_composite(img, overlay_draw)

    # Guardar
    if output_path is None:
        RENDERS_DIR.mkdir(parents=True, exist_ok=True)
        safe_name = map_path.stem
        output_path = RENDERS_DIR / f"{safe_name}.png"

    img.save(output_path, "PNG")
    return output_path


def render_all_maps(limit: int = None):
    """Renderiza todos los mapas JSON disponibles en out/maps/."""
    RENDERS_DIR.mkdir(parents=True, exist_ok=True)
    map_files = sorted(MAPS_DIR.glob("*.json"))
    if limit:
        map_files = map_files[:limit]

    print(f"=== Renderizando {len(map_files)} mapas a PNG ===")
    count = 0
    for mp in map_files:
        try:
            out_file = render_map(mp)
            count += 1
            if count % 20 == 0 or count == len(map_files):
                print(f"  [{count}/{len(map_files)}] Renderizado {mp.name} -> {out_file.name}")
        except Exception as e:
            print(f"  [ERR] Error al renderizar {mp.name}: {e}")

    print(f"[OK] Total de mapas renderizados: {count}")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--all":
        render_all_maps()
    elif len(sys.argv) > 1 and sys.argv[1].isdigit():
        render_all_maps(limit=int(sys.argv[1]))
    else:
        # Por defecto renderizar 10 mapas representativos para el checkpoint de T2.7
        sample_maps = [
            "m_m_00.json", # Aldea Silverleaf
            "m_m_01.json", # Chelen / Aldea destruida
            "m_m_02.json", # Aldea Melon
            "m_m_03.json", # Ciudad Humming
            "m_m_04.json", # Humming centro
            "m_m_06.json", # Ciudad Ciruelo
            "m_m_07.json", # Orfanato
            "m_m_50.json", # Pantano
            "m_m_62.json", # Jardín de Huesos
            "m_m2_c1.json" # Jefe 1: Anthony
        ]
        RENDERS_DIR.mkdir(parents=True, exist_ok=True)
        print("=== Renderizando 10 mapas representativos para Checkpoint T2.7 ===")
        for s in sample_maps:
            p = MAPS_DIR / s
            if p.exists():
                out = render_map(p)
                print(f"  [OK] Renderizado: {s} -> {out.name}")
