"""
tools/hero_anim_debugger.py
===========================
Herramienta de depuración y auditoría visual de animaciones de Lucian (Heroes Lore: Zero).
Genera hojas de contacto numeradas con guías de alineación, límites de fotogramas,
capas de armas y puntos de apoyo auténticos.
"""

import os
import sys
import json
import struct
import zipfile
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

REPO_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO_ROOT))

import tools.build_authentic_remaster as b

JAR_PATH = REPO_ROOT / "input" / "Heroes Lore Zero 360x640 Spanish.jar"
OUT_DIR = REPO_ROOT / "out" / "debug_anims"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# Colores para identificar cada capa en el modo depuración
LAYER_COLORS = [
    (230, 80, 80, 200),    # 0: Cabello (Rojo claro)
    (180, 100, 50, 200),   # 1: Torso / Chaleco (Marrón/Rojo oscuro)
    (140, 80, 200, 200),   # 2: Pantalón / Brazos (Morado)
    (70, 70, 90, 200),     # 3: Botas (Gris azulado)
    (255, 200, 50, 220),   # 4: VFX / Rayos de corte (Dorado / Amarillo)
    (50, 220, 200, 220),   # 5: Ojos (Cian)
    (50, 150, 255, 220),   # 6: Arma Principal (Azul brillante)
    (80, 220, 120, 220),   # 7: Arma Secundaria / Escudo (Verde / Esmeralda)
]

DIR_NAMES = ["North (Espalda)", "South (Frente)", "West (Izquierda)", "East (Derecha)"]


def load_hero_composite(z: zipfile.ZipFile, class_id: int, w_main: str, w_off: str = None):
    h_path = f"hero/h{class_id}"
    h_data = z.read(h_path)
    nl = h_data[0]
    p = nl + 1
    layers_meta = []
    for _ in range(nl):
        v5 = h_data[p]; p += 1
        v2 = h_data[p]; p += 1
        layers_meta.append((v5, v2))
        p += v2 + v5
    na = h_data[p]; p += 1

    anims = []
    for a in range(na):
        fc = h_data[p]; p += 1
        anim_data = {"anim": a, "fc": fc, "frames": []}
        for f in range(fc):
            dirs = []
            for d in range(4):
                np = h_data[p]; p += 1
                parts = []
                for _ in range(np):
                    b0, b1 = h_data[p], h_data[p+1]
                    dx = struct.unpack("b", bytes([h_data[p+2]]))[0]
                    dy = struct.unpack("b", bytes([h_data[p+3]]))[0]
                    p += 4
                    parts.append({
                        "layer": b0 & 127,
                        "flipped": (b0 >> 7 != 0),
                        "slice": b1,
                        "dx": dx,
                        "dy": dy
                    })
                dirs.append(parts)
            anim_data["frames"].append(dirs)
        anims.append(anim_data)

    # Resolución exacta de rutas según rpg/c.java
    is_even = (class_id % 2 == 0)
    arm_prefix = "" if is_even else "l"
    layer_paths = [
        "hero/0/00",
        f"hero/1/{arm_prefix}00",
        f"hero/2/{arm_prefix}00",
        f"hero/3/{arm_prefix}00",
        f"hero/4/{class_id}",
        "hero/eh",
        w_main
    ]
    if nl >= 8:
        layer_paths.append(w_off)

    layers_normal = []
    for lp in layer_paths[:nl]:
        if lp:
            layers_normal.append(b.load_mpm(z, lp))
        else:
            layers_normal.append([])

    layers_flipped = [[img.transpose(Image.FLIP_LEFT_RIGHT) for img in l] for l in layers_normal]
    all_layers = layers_normal + layers_flipped

    return nl, anims, all_layers


def render_debug_frame(nl, anims, all_layers, anim_id: int, dir_idx: int, frame_idx: int,
                       canvas_w: int = 64, canvas_h: int = 80,
                       anchor_x: int = 32, anchor_y: int = 60,
                       draw_boxes: bool = False):
    """
    Renderiza un fotograma único con o sin cajas de delimitación de capas.
    """
    canvas = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
    boxes_info = []

    parts = anims[anim_id]["frames"][frame_idx][dir_idx]
    for p in parts:
        l_idx = p["layer"] + (nl if p["flipped"] else 0)
        s_idx = p["slice"]
        orig_layer = p["layer"]
        if l_idx < len(all_layers) and s_idx < len(all_layers[l_idx]):
            slice_img = all_layers[l_idx][s_idx]
            px = anchor_x + p["dx"]
            py = anchor_y + p["dy"]
            canvas.paste(slice_img, (px, py), slice_img)
            boxes_info.append({
                "layer": orig_layer,
                "flipped": p["flipped"],
                "box": (px, py, px + slice_img.width, py + slice_img.height)
            })

    return canvas, boxes_info


def generate_numbered_contact_sheet(nl, anims, all_layers, anim_id: int,
                                   title: str, class_name: str,
                                   canvas_w: int = 64, canvas_h: int = 80,
                                   anchor_x: int = 32, anchor_y: int = 60,
                                   scale: int = 4, show_debug_boxes: bool = False):
    fc = anims[anim_id]["fc"]
    thumb_w = canvas_w * scale
    thumb_h = canvas_h * scale
    header_h = 60
    row_header_w = 170

    sheet_w = row_header_w + fc * thumb_w
    sheet_h = header_h + 4 * thumb_h

    sheet = Image.new("RGBA", (sheet_w, sheet_h), (24, 27, 34, 255))
    draw = ImageDraw.Draw(sheet)

    # Título principal
    draw.text((12, 10), f"{class_name} — {title}", fill=(255, 215, 80, 255))
    draw.text((12, 32), f"Anim {anim_id} | {fc} fotogramas | Origen anclaje: ({anchor_x}, {anchor_y}) | Suelo Y={anchor_y+5}",
              fill=(180, 190, 205, 255))

    # Encabezados de columnas
    for f in range(fc):
        x = row_header_w + f * thumb_w
        draw.text((x + 10, 36), f"Fotograma {f}", fill=(210, 220, 240, 255))

    # Filas por dirección
    for d_idx, d_name in enumerate(DIR_NAMES):
        y = header_h + d_idx * thumb_h
        draw.text((12, y + thumb_h // 2 - 8), d_name, fill=(160, 200, 255, 255))

        for f in range(fc):
            x = row_header_w + f * thumb_w

            # Fondo ajedrezado
            for cy in range(0, thumb_h, 16):
                for cx in range(0, thumb_w, 16):
                    c = (38, 42, 50) if ((cx // 16 + cy // 16) % 2 == 0) else (32, 36, 44)
                    draw.rectangle([x + cx, y + cy, x + cx + 15, y + cy + 15], fill=c)

            # Línea de suelo (ground plane)
            ground_y = y + (anchor_y + 5) * scale
            draw.line([x, ground_y, x + thumb_w, ground_y], fill=(55, 75, 95, 255), width=2)

            # Sombra de pies
            shadow_cx = x + anchor_x * scale
            draw.ellipse([shadow_cx - 24, ground_y - 6, shadow_cx + 24, ground_y + 6], fill=(12, 15, 20, 160))

            # Renderizado del fotograma
            frame_img, boxes = render_debug_frame(
                nl, anims, all_layers, anim_id, d_idx, f,
                canvas_w, canvas_h, anchor_x, anchor_y
            )
            frame_4x = b.upscale_4x(frame_img)
            sheet.paste(frame_4x, (x, y), frame_4x)

            # Cajas de delimitación por capa (si está activo el modo debug)
            if show_debug_boxes:
                for b_info in boxes:
                    col = LAYER_COLORS[b_info["layer"] % len(LAYER_COLORS)]
                    bx0, by0, bx1, by1 = b_info["box"]
                    draw.rectangle([
                        x + bx0 * scale, y + by0 * scale,
                        x + bx1 * scale - 1, y + by1 * scale - 1
                    ], outline=col, width=1)

            # Borde de celda
            draw.rectangle([x, y, x + thumb_w - 1, y + thumb_h - 1], outline=(60, 65, 75, 255))

            # Punto de apoyo (Cruz roja en pies)
            cx_anchor = x + anchor_x * scale
            cy_anchor = ground_y
            draw.line([cx_anchor - 6, cy_anchor, cx_anchor + 6, cy_anchor], fill=(255, 40, 40, 220), width=2)
            draw.line([cx_anchor, cy_anchor - 6, cx_anchor, cy_anchor + 6], fill=(255, 40, 40, 220), width=2)

    return sheet


def main():
    print("=================================================================")
    print("HEROES LORE: ZERO — AUDITOR DE ANIMACIONES Y GENERADOR DE HOJAS")
    print("=================================================================")

    z = zipfile.ZipFile(JAR_PATH)

    # 1. Asesino (Class 1) - Doble Daga
    print("\n[1/2] Auditoria Clase Asesino (hero/h1, hero/w/400 x2, hero/1/l00, hero/4/1)...")
    nl_asn, anims_asn, layers_asn = load_hero_composite(z, 1, "hero/w/400", "hero/w/400")

    sheets_to_gen = [
        (0, "Reposo de Combate (Idle)", "sheet_asn_00_idle.png"),
        (1, "Marcha Pacífica / Aldea (Village Walk)", "sheet_asn_01_walk_peaceful.png"),
        (2, "Marcha de Combate (Combat Walk con Dagas)", "sheet_asn_02_walk_combat.png"),
        (6, "Ataque Básico Combo 1 (5 Frames con Tajos VFX)", "sheet_asn_06_attack_combo1.png"),
        (7, "Remate Aéreo Combo 2 (3 Frames con Tajo Descendente)", "sheet_asn_07_attack_finisher.png"),
        (4, "Caída / Muerte (Death Animation)", "sheet_asn_04_death.png"),
    ]

    for a_id, title, fname in sheets_to_gen:
        sheet = generate_numbered_contact_sheet(
            nl_asn, anims_asn, layers_asn, a_id,
            title, "Lucian Asesino (Doble Daga)",
            show_debug_boxes=False
        )
        sheet.save(OUT_DIR / fname)
        print(f"  -> Guardado: {OUT_DIR / fname}")

    # Hoja con cajas de depuración de capas para el ataque
    sheet_dbg = generate_numbered_contact_sheet(
        nl_asn, anims_asn, layers_asn, 6,
        "Ataque Combo 1 — Desglose de Capas y Cajas de Delimitación",
        "Lucian Asesino",
        show_debug_boxes=True
    )
    sheet_dbg.save(OUT_DIR / "sheet_asn_06_debug_layers.png")
    print(f"  -> Guardado: {OUT_DIR / 'sheet_asn_06_debug_layers.png'}")

    # 2. Guerrero (Class 0) - Espadón Claymore
    print("\n[2/2] Auditoria Clase Guerrero (hero/h0, hero/w/100, hero/1/00, hero/4/0)...")
    nl_war, anims_war, layers_war = load_hero_composite(z, 0, "hero/w/100", None)

    sheets_war = [
        (0, "Reposo de Combate (Idle con Espadón)", "sheet_war_00_idle.png"),
        (2, "Marcha de Combate (Combat Walk con Espadón)", "sheet_war_02_walk_combat.png"),
        (6, "Tajo Básico con Espadón (6 Frames con Arco de Energía)", "sheet_war_06_attack.png"),
    ]

    for a_id, title, fname in sheets_war:
        sheet = generate_numbered_contact_sheet(
            nl_war, anims_war, layers_war, a_id,
            title, "Lucian Guerrero (Espadón Azul)",
            show_debug_boxes=False
        )
        sheet.save(OUT_DIR / fname)
        print(f"  -> Guardado: {OUT_DIR / fname}")

    print("\n¡Todas las hojas de contacto generadas exitosamente en out/debug_anims/!")


if __name__ == "__main__":
    main()
