"""
tools/build_authentic_pixel_assets.py
Construye el conjunto de activos visuales genuinos 4x (Pixel-Perfect) de Heroes Lore: Zero:
1. Aldea Silverleaf (map_silverleaf.png) renderizada a partir de los tilesets originales a 4x (1792x2560 px).
2. Sprites auténticos de Lucian Asesino (Class 2) en 4 direcciones (Down, Up, Side) a escala 4x centrados en canvas de 128x128 con pivote en los pies (y=124).
3. Fotogramas del ciclo de marcha (Walk) y ataque (Dual Daggers).
"""

import os
import json
import zipfile
from pathlib import Path
from PIL import Image

REPO_ROOT = Path(__file__).resolve().parent.parent
JAR_PATH = REPO_ROOT / "input" / "Heroes Lore Zero 360x640 Spanish.jar"
SPRITES_DIR = REPO_ROOT / "out" / "sprites"
MAPS_DIR = REPO_ROOT / "out" / "maps"
GODOT_ART = REPO_ROOT / "godot" / "art_samples"
FINAL_ART = REPO_ROOT / "art" / "final" / "sample_batch"

def load_slices(folder_rel: str):
    folder = SPRITES_DIR / "hero" / folder_rel
    if not folder.exists():
        return []
    return [Image.open(f).convert("RGBA") for f in sorted(folder.glob("*.png"))]

def load_tileset(ts_id: int):
    folder = SPRITES_DIR / "m" / f"t{ts_id:02d}"
    if not folder.exists():
        return []
    return [Image.open(f).convert("RGBA") for f in sorted(folder.glob("*.png"))]

def render_silverleaf_4x():
    print("=== 1. Renderizando Mapa Original de Aldea Silverleaf (4x Pixel-Perfect) ===")
    with open(MAPS_DIR / "m_m_00.json", "r", encoding="utf-8") as f:
        m = json.load(f)

    ts0_id = m.get("tileset_0", 0)
    ts1_id = m.get("tileset_1", 26)
    width = m["width"]
    height = m["height"]
    ground = m.get("ground_layer", [])
    overlay = m.get("overlay_layer", [])

    tiles_0 = load_tileset(ts0_id)
    tiles_1 = load_tileset(ts1_id) if ts1_id != 255 else []
    all_tiles = tiles_0 + tiles_1
    split = len(tiles_0)

    # 1. Capa de suelo
    img_ground = Image.new("RGBA", (width * 16, height * 16), (252, 251, 247, 255))
    for y in range(height):
        for x in range(width):
            idx = y * width + x
            if idx < len(ground):
                val = ground[idx]
                offset = split if (val & 128) != 0 else 0
                t_idx = offset + (val & 127) - 1
                if 0 <= t_idx < len(all_tiles):
                    t = all_tiles[t_idx]
                    img_ground.paste(t, (x * 16, y * 16), t)

    # 2. Capa de superposición
    img_overlay = Image.new("RGBA", (width * 16, height * 16), (0, 0, 0, 0))
    for y in range(height):
        for x in range(width):
            idx = y * width + x
            if idx < len(overlay):
                val = overlay[idx]
                tile_val = val & 63
                if tile_val > 0:
                    offset = split if (val & 128) != 0 else 0
                    t_idx = offset + tile_val - 1
                    if 0 <= t_idx < len(all_tiles):
                        t = all_tiles[t_idx]
                        img_overlay.paste(t, (x * 16, y * 16), t)

    # Imagen combinada completa
    img_full = Image.alpha_composite(img_ground, img_overlay)
    
    # Escalado entero 4x (Nearest-Neighbor para pixel art cristalino)
    img_4x = img_full.resize((width * 64, height * 64), Image.NEAREST)
    
    out_path_godot = GODOT_ART / "map_silverleaf.png"
    out_path_final = FINAL_ART / "map_silverleaf.png"
    img_4x.save(out_path_godot, "PNG")
    img_4x.save(out_path_final, "PNG")
    print(f"  [OK] Guardado {out_path_godot.name}: {img_4x.size}")
    return img_4x


def composite_character_frame(h_data, anim_idx, frame_idx, dir_idx, layer_images, canvas_w=32, canvas_h=32, origin_x=16, origin_y=28):
    """Compone un fotograma exacto del héroe a partir de la tabla binaria h_data."""
    var4 = h_data[0]
    var3 = var4 + 1
    for _ in range(var4):
        v5 = h_data[var3]; var3 += 1
        v2 = h_data[var3]; var3 += 1
        var3 += v2 + v5
    num_anims = h_data[var3]; var3 += 1

    canvas = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))

    for a in range(num_anims):
        num_frames = h_data[var3]; var3 += 1
        for f in range(num_frames):
            for d in range(4):
                num_parts = h_data[var3]; var3 += 1
                parts = []
                for _ in range(num_parts):
                    raw_layer = h_data[var3]
                    slice_idx = h_data[var3 + 1]
                    ox = h_data[var3 + 2]
                    if ox > 127: ox -= 256
                    oy = h_data[var3 + 3]
                    if oy > 127: oy -= 256
                    parts.append((raw_layer, slice_idx, ox, oy))
                    var3 += 4

                if a == anim_idx and f == frame_idx and d == dir_idx:
                    for raw_layer, slice_idx, ox, oy in parts:
                        flip = (raw_layer & 128) != 0
                        layer_idx = raw_layer & 127
                        if layer_idx in layer_images:
                            imgs = layer_images[layer_idx]
                            if slice_idx < len(imgs):
                                part_img = imgs[slice_idx]
                                if flip:
                                    part_img = part_img.transpose(Image.FLIP_LEFT_RIGHT)
                                canvas.paste(part_img, (origin_x + ox, origin_y + oy), part_img)
    return canvas


def build_lucian_assassin_sprites():
    print("\n=== 2. Componiendo Sprites Originales de Lucian Asesino (Class 2) ===")
    with zipfile.ZipFile(JAR_PATH, "r") as z:
        h2 = z.read("hero/h2")

    layer_images = {
        0: load_slices("0/t"),
        1: load_slices("2/00"),
        2: load_slices("2/l00"),
        3: load_slices("0/t"),
        4: load_slices("eh"),
        6: load_slices("w/200"), # Daga 1
        7: load_slices("w/200")  # Daga 2
    }

    # Direcciones canónicas: 0: Down (Sur), 1: Up (Norte), 2: Left (Oeste), 3: Right (Este)
    dir_indices = {
        "down": 0,
        "up": 1,
        "side": 3 # Right (Este), Left se refleja con flip_h
    }

    for dir_name, dir_idx in dir_indices.items():
        # Animación 0 (Walk), frame 0 para pose base
        frame_1x = composite_character_frame(h2, 0, 0, dir_idx, layer_images, canvas_w=32, canvas_h=32, origin_x=16, origin_y=28)
        
        # Encontrar bounding box y posicionar sobre lienzo de 128x128 con pies en y=124
        bbox = frame_1x.getbbox()
        if bbox:
            minx, miny, maxx, maxy = bbox
            char_w = maxx - minx
            char_h = maxy - miny
            crop_1x = frame_1x.crop(bbox)
            
            # Escalar 4x con vecino más próximo
            crop_4x = crop_1x.resize((char_w * 4, char_h * 4), Image.NEAREST)
            
            canvas_128 = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
            # Centrar horizontalmente en x=64, colocar pies en y=124
            paste_x = 64 - (crop_4x.width // 2)
            paste_y = 124 - crop_4x.height
            canvas_128.paste(crop_4x, (paste_x, paste_y), crop_4x)
            
            out_name = f"hero_lucian_{dir_name}.png"
            canvas_128.save(GODOT_ART / out_name, "PNG")
            canvas_128.save(FINAL_ART / out_name, "PNG")
            print(f"  [OK] Guardado {out_name} (pies en y=124, tam={crop_4x.size})")
            
            if dir_name == "down":
                canvas_128.save(GODOT_ART / "hero_lucian_idle.png", "PNG")
                canvas_128.save(FINAL_ART / "hero_lucian_idle.png", "PNG")

    # Guardar fotogramas de caminata (8 frames) para animación completa
    print("\n=== 3. Extrayendo los 8 Fotogramas del Ciclo de Marcha (Walk) ===")
    for d_name, d_idx in [("down", 0), ("up", 1), ("side", 3)]:
        for f_idx in range(8):
            f1x = composite_character_frame(h2, 0, f_idx, d_idx, layer_images, canvas_w=32, canvas_h=32, origin_x=16, origin_y=28)
            bbox = f1x.getbbox()
            canvas_128 = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
            if bbox:
                crop_4x = f1x.crop(bbox).resize(((bbox[2] - bbox[0]) * 4, (bbox[3] - bbox[1]) * 4), Image.NEAREST)
                paste_x = 64 - (crop_4x.width // 2)
                paste_y = 124 - crop_4x.height
                canvas_128.paste(crop_4x, (paste_x, paste_y), crop_4x)
            
            fn = f"hero_lucian_walk_{d_name}_{f_idx}.png"
            canvas_128.save(GODOT_ART / fn, "PNG")

    print("[EXITO] Todos los activos genuinos han sido generados.")

if __name__ == "__main__":
    render_silverleaf_4x()
    build_lucian_assassin_sprites()
