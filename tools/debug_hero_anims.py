"""
tools/debug_hero_anims.py
=========================
Herramienta de diagnóstico y generación de hojas de contacto para las animaciones
de Lucian en Heroes Lore: Zero.
Extrae y renderiza cada fotograma con guías de alineación, origen y capas.
"""

import os
import struct
import zipfile
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

REPO_ROOT = Path(__file__).resolve().parent.parent
JAR_PATH = REPO_ROOT / "input" / "Heroes Lore Zero 360x640 Spanish.jar"
OUT_DIR = REPO_ROOT / "out" / "debug_anims"
import sys
sys.path.insert(0, str(REPO_ROOT))
OUT_DIR.mkdir(parents=True, exist_ok=True)
import tools.build_authentic_remaster as b


def parse_h_file(z: zipfile.ZipFile, h_path: str):
    data = z.read(h_path)
    num_layers = data[0]
    var3 = num_layers + 1
    layers_meta = []
    for i in range(num_layers):
        v5 = data[var3]; var3 += 1
        v2 = data[var3]; var3 += 1
        layers_meta.append((v5, v2))
        var3 += v2 + v5
    num_anims = data[var3]; var3 += 1
    anims = []
    base_off = var3
    for a in range(num_anims):
        fc = data[var3]; var3 += 1
        anim_data = {"anim": a, "frame_count": fc, "frames": []}
        for f in range(fc):
            dirs = []
            for d in range(4):
                np = data[var3]; var3 += 1
                parts = []
                for _ in range(np):
                    b0 = data[var3]
                    b1 = data[var3 + 1]
                    dx = struct.unpack("b", bytes([data[var3 + 2]]))[0]
                    dy = struct.unpack("b", bytes([data[var3 + 3]]))[0]
                    var3 += 4
                    parts.append({
                        "layer": b0 & 127,
                        "flipped": (b0 >> 7 != 0),
                        "slice": b1,
                        "dx": dx,
                        "dy": dy,
                    })
                dirs.append(parts)
            anim_data["frames"].append(dirs)
        anims.append(anim_data)
    return num_layers, layers_meta, anims


def create_renderer(z: zipfile.ZipFile, class_id: int, w6_path: str = None, w7_path: str = None):
    # Layers according to rpg/c.java:
    # Layer 0: Hair (/hero/0/00)
    # Layer 1: Body/Torso (/hero/1/00)
    # Layer 2: Pants (/hero/2/00)
    # Layer 3: Boots (/hero/3/00)
    # Layer 4: Headgear (/hero/4/{class_id})
    # Layer 5: Eyes (/hero/eh)
    # Layer 6: Main weapon
    # Layer 7: Offhand weapon
    h_path = f"hero/h{class_id}"
    num_layers, layers_meta, anims = parse_h_file(z, h_path)

    layer_paths = [
        "hero/0/00", "hero/1/00", "hero/2/00", "hero/3/00",
        f"hero/4/{class_id}", "hero/eh", w6_path
    ]
    if num_layers >= 8:
        layer_paths.append(w7_path)

    layers_normal = []
    for p in layer_paths[:num_layers]:
        if p is not None:
            layers_normal.append(b.load_mpm(z, p))
        else:
            layers_normal.append([])

    layers_flipped = [[img.transpose(Image.FLIP_LEFT_RIGHT) for img in l] for l in layers_normal]
    all_layers = layers_normal + layers_flipped

    def render_part_by_part(anim_id: int, dir_idx: int, frame_idx: int, canvas_size: int = 64):
        # Canvas centered: feet at (canvas_size//2, canvas_size - 12)
        center_x = canvas_size // 2
        feet_y = canvas_size - 12

        canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
        parts = anims[anim_id]["frames"][frame_idx][dir_idx]

        for p in parts:
            l_idx = p["layer"] + (num_layers if p["flipped"] else 0)
            s_idx = p["slice"]
            if l_idx < len(all_layers) and s_idx < len(all_layers[l_idx]):
                slice_img = all_layers[l_idx][s_idx]
                canvas.paste(slice_img, (center_x + p["dx"], feet_y + p["dy"]), slice_img)
        return canvas

    return render_part_by_part, anims


def generate_contact_sheet(render_fn, anim_data, anim_id: int, title: str, canvas_size: int = 64):
    fc = anim_data[anim_id]["frame_count"]
    # 4 directions:
    # dir_idx 0 = North (Dir 1)
    # dir_idx 1 = South (Dir 2)
    # dir_idx 2 = West  (Dir 3)
    # dir_idx 3 = East  (Dir 4)
    dir_names = ["North (Espalda)", "South (Frente)", "West (Izquierda)", "East (Derecha)"]

    scale = 4
    thumb_w = canvas_size * scale
    thumb_h = canvas_size * scale
    header_h = 40
    row_header_w = 160

    sheet_w = row_header_w + fc * thumb_w
    sheet_h = header_h + 4 * thumb_h

    sheet = Image.new("RGBA", (sheet_w, sheet_h), (30, 34, 40, 255))
    draw = ImageDraw.Draw(sheet)

    # Title
    draw.text((10, 10), f"{title} (Anim {anim_id}, {fc} fotogramas)", fill=(255, 220, 100, 255))

    for f in range(fc):
        x = row_header_w + f * thumb_w
        draw.text((x + 10, 15), f"F{f}", fill=(200, 200, 200, 255))

    for d_idx, d_name in enumerate(dir_names):
        y = header_h + d_idx * thumb_h
        draw.text((10, y + thumb_h // 2 - 10), d_name, fill=(180, 210, 255, 255))

        for f in range(fc):
            x = row_header_w + f * thumb_w
            # Checkerboard background for transparency visibility
            for cy in range(0, thumb_h, 16):
                for cx in range(0, thumb_w, 16):
                    c = (45, 49, 58) if ((cx // 16 + cy // 16) % 2 == 0) else (38, 42, 50)
                    draw.rectangle([x + cx, y + cy, x + cx + 15, y + cy + 15], fill=c)

            # Draw frame
            frame_img = render_fn(anim_id, d_idx, f, canvas_size)
            frame_4x = b.upscale_4x(frame_img)
            sheet.paste(frame_4x, (x, y), frame_4x)

            # Draw border
            draw.rectangle([x, y, x + thumb_w - 1, y + thumb_h - 1], outline=(70, 75, 85, 255))

            # Mark anchor point (feet)
            cx_anchor = x + (canvas_size // 2) * scale
            cy_anchor = y + (canvas_size - 12) * scale
            draw.line([cx_anchor - 6, cy_anchor, cx_anchor + 6, cy_anchor], fill=(255, 50, 50, 200))
            draw.line([cx_anchor, cy_anchor - 6, cx_anchor, cy_anchor + 6], fill=(255, 50, 50, 200))

    return sheet


def main():
    z = zipfile.ZipFile(JAR_PATH)

    print("Analizando animaciones de Lucian en hero/h2...")
    # Test 1: Class 2 with Greatsword (w/100) vs Dagger (w/200 & w/700)
    r_dagger, anims_dagger = create_renderer(z, class_id=2, w6_path="hero/w/200", w7_path="hero/w/700")
    r_sword, anims_sword = create_renderer(z, class_id=0, w6_path="hero/w/100", w7_path=None)

    # Anim 0 = Idle
    sheet_idle_dagger = generate_contact_sheet(r_dagger, anims_dagger, 0, "Lucian Asesino (Doble Daga 200+700) — Reposo (Idle)")
    sheet_idle_dagger.save(OUT_DIR / "sheet_lucian_idle_daggers.png")
    print(f"  -> Guardado {OUT_DIR / 'sheet_lucian_idle_daggers.png'}")

    # Anim 1 = Walk
    sheet_walk_dagger = generate_contact_sheet(r_dagger, anims_dagger, 1, "Lucian Asesino (Doble Daga 200+700) — Caminar (Walk)")
    sheet_walk_dagger.save(OUT_DIR / "sheet_lucian_walk_daggers.png")
    print(f"  -> Guardado {OUT_DIR / 'sheet_lucian_walk_daggers.png'}")

    # Anim 2 = Attack
    sheet_atk_dagger = generate_contact_sheet(r_dagger, anims_dagger, 2, "Lucian Asesino (Doble Daga 200+700) — Ataque Básico (Attack)")
    sheet_atk_dagger.save(OUT_DIR / "sheet_lucian_atk_daggers.png")
    print(f"  -> Guardado {OUT_DIR / 'sheet_lucian_atk_daggers.png'}")

    # Also generate sheet for Class 0 (Guerrero - Espadón 100)
    sheet_idle_sword = generate_contact_sheet(r_sword, anims_sword, 0, "Lucian Guerrero (Espada 100) — Reposo (Idle)")
    sheet_idle_sword.save(OUT_DIR / "sheet_lucian_idle_sword.png")

    sheet_walk_sword = generate_contact_sheet(r_sword, anims_sword, 1, "Lucian Guerrero (Espada 100) — Caminar (Walk)")
    sheet_walk_sword.save(OUT_DIR / "sheet_lucian_walk_sword.png")

    sheet_atk_sword = generate_contact_sheet(r_sword, anims_sword, 2, "Lucian Guerrero (Espada 100) — Ataque Básico (Attack)")
    sheet_atk_sword.save(OUT_DIR / "sheet_lucian_atk_sword.png")

    print("\nHojas de contacto generadas exitosamente en out/debug_anims/")


if __name__ == "__main__":
    main()
