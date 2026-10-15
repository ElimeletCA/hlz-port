#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys, io
if sys.stdout.encoding and sys.stdout.encoding.lower() != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')
"""
tools/build_directional_lucian.py

Procesa las 3 vistas direccionales canónicas de Lucian Asesino:
- Front / Down: lucian_assassin_mirrored.jpg -> hero_lucian_down.png
- Back / Up: lucian_back_view_sprite_1792100291958.jpg -> hero_lucian_up.png
- Side / Right: lucian_sprite_east_stride_1792100287148.jpg -> hero_lucian_side.png

Para cada vista:
1. Flood-fill desde las 4 esquinas para extraer el fondo blanco limpiamente.
2. Descontamina halos blancos en los bordes.
3. Bounding box tight y escalado a ~120 px de altura dentro de canvas 128x128.
4. Alineación precisa de pies en y = 124 (para offset 0, -64 en Godot).
5. Exportación a art/final/sample_batch/ y godot/art_samples/.
6. Genera .import, .ctex y .md5 en Godot.
"""

import os
import sys
import numpy as np
from PIL import Image
from collections import deque

BASE_DIR = r"C:\Users\ACER\.gemini\antigravity\brain\24cf1964-19cb-471c-8f58-abab7d5e9d16"
GODOT_ART = r"C:\Proyecto HLZ\hlz-port\godot\art_samples"
FINAL_ART = r"C:\Proyecto HLZ\hlz-port\art\final\sample_batch"

VIEWS = {
    "down": {
        "src": os.path.join(BASE_DIR, "lucian_assassin_mirrored.jpg"),
        "dest": "hero_lucian_down.png"
    },
    "up": {
        "src": os.path.join(BASE_DIR, "lucian_back_view_sprite_1792100291958.jpg"),
        "dest": "hero_lucian_up.png"
    },
    "side": {
        "src": os.path.join(BASE_DIR, "lucian_sprite_east_stride_1792100287148.jpg"),
        "dest": "hero_lucian_side.png"
    }
}

TARGET_W = 128
TARGET_H = 128


def clean_background(img: Image.Image) -> Image.Image:
    """Elimina fondo blanco usando flood-fill y antialiasing descontaminado."""
    rgba = img.convert("RGBA")
    w, h = rgba.size
    pixels = np.array(rgba, dtype=np.float32)

    r = pixels[:, :, 0]
    g = pixels[:, :, 1]
    b = pixels[:, :, 2]
    is_white = (r > 235) & (g > 235) & (b > 235)

    visited = np.zeros((h, w), dtype=bool)
    queue = deque()

    for x in range(w):
        if is_white[0, x]:
            queue.append((0, x))
            visited[0, x] = True
        if is_white[h - 1, x]:
            queue.append((h - 1, x))
            visited[h - 1, x] = True
    for y in range(h):
        if is_white[y, 0]:
            queue.append((y, 0))
            visited[y, 0] = True
        if is_white[y, w - 1]:
            queue.append((y, w - 1))
            visited[y, w - 1] = True

    while queue:
        cy, cx = queue.popleft()
        for dy, dx in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            ny, nx = cy + dy, cx + dx
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx]:
                if is_white[ny, nx]:
                    visited[ny, nx] = True
                    queue.append((ny, nx))

    alpha = np.ones((h, w), dtype=np.float32) * 255.0

    for y in range(h):
        for x in range(w):
            if visited[y, x]:
                brightness = min(r[y, x], g[y, x], b[y, x])
                if brightness >= 248:
                    alpha[y, x] = 0.0
                elif brightness >= 225:
                    t = (brightness - 225.0) / (248.0 - 225.0)
                    alpha[y, x] = (1.0 - t) * 255.0
                    factor = max(0.1, 1.0 - t)
                    pixels[y, x, 0] = min(255, pixels[y, x, 0] * factor)
                    pixels[y, x, 1] = min(255, pixels[y, x, 1] * factor)
                    pixels[y, x, 2] = min(255, pixels[y, x, 2] * factor)
                else:
                    alpha[y, x] = 0.0

    pixels[:, :, 3] = alpha
    return Image.fromarray(np.uint8(np.clip(pixels, 0, 255)), mode="RGBA")


def crop_and_fit(img: Image.Image, canvas_w: int, canvas_h: int) -> Image.Image:
    """Recorta la silueta del personaje y la ajusta al canvas centrado con pies abajo."""
    alpha = np.array(img)[:, :, 3]
    ys, xs = np.where(alpha > 10)
    if len(ys) == 0:
        return img

    min_y, max_y = ys.min(), ys.max()
    min_x, max_x = xs.min(), xs.max()

    cropped = img.crop((min_x, min_y, max_x + 1, max_y + 1))
    crop_w, crop_h = cropped.size

    target_char_h = 120
    scale = target_char_h / float(crop_h)
    new_w = int(round(crop_w * scale))
    new_h = target_char_h

    # Si es muy ancho (e.g. side stride), limitar ancho a 124 px
    if new_w > canvas_w - 4:
        scale_w = (canvas_w - 4) / float(new_w)
        new_w = canvas_w - 4
        new_h = int(round(new_h * scale_w))

    resized = cropped.resize((new_w, new_h), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))

    pos_x = (canvas_w - new_w) // 2
    pos_y = canvas_h - new_h - 4

    canvas.paste(resized, (pos_x, pos_y), resized)
    return canvas


def main():
    print("=" * 60)
    print("  Construcción de Sprites Direccionales: Lucian Asesino")
    print("=" * 60)

    for direction, info in VIEWS.items():
        src_path = info["src"]
        dest_filename = info["dest"]

        print(f"\n[DIRECCION: {direction.upper()}]")
        print(f"  Fuente: {src_path}")

        if not os.path.exists(src_path):
            print(f"  [ERROR] No existe archivo: {src_path}")
            continue

        raw = Image.open(src_path)
        print(f"  Tamaño original: {raw.size}")

        print("  Limpiando fondo blanco...")
        cleaned = clean_background(raw)

        print(f"  Ajustando a canvas de {TARGET_W}x{TARGET_H}...")
        fitted = crop_and_fit(cleaned, TARGET_W, TARGET_H)

        p1 = os.path.join(FINAL_ART, dest_filename)
        p2 = os.path.join(GODOT_ART, dest_filename)

        fitted.save(p1, "PNG")
        fitted.save(p2, "PNG")
        print(f"  ✓ Guardado en {p2}")

        # Si es down, actualizar también hero_lucian_idle.png
        if direction == "down":
            p_idle1 = os.path.join(FINAL_ART, "hero_lucian_idle.png")
            p_idle2 = os.path.join(GODOT_ART, "hero_lucian_idle.png")
            fitted.save(p_idle1, "PNG")
            fitted.save(p_idle2, "PNG")

    print("\nRegenerando imports de Godot...")
    # Importar el generador
    sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
    import generar_import_godot

    for fn in ["hero_lucian_down.png", "hero_lucian_up.png", "hero_lucian_side.png", "hero_lucian_idle.png"]:
        generar_import_godot.procesar_asset(fn, forzar=True)

    print("\n✓ Todos los sprites direccionales integrados exitosamente.")


if __name__ == "__main__":
    main()
