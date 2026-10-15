#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
tools/process_lucian_sprite.py

Procesa el concept art de Lucian Asesino (Opción 2):
1. Detecta el fondo blanco exterior mediante flood-fill desde las esquinas.
2. Elimina el fondo blanco preservando los brillos internos (ojos, reflejos de dagas).
3. Descontamina bordes (antialiasing limpio sin halo blanco).
4. Centra al personaje horizontalmente y posiciona sus pies en la base.
5. Escala y ajusta a un canvas limpio de 128x128 px para Godot con offset (0, -64).
6. Exporta a art/final/sample_batch/ y godot/art_samples/.
7. Regenera los archivos .import, .ctex y .md5 de Godot.
"""

import os
import sys
import numpy as np
from PIL import Image
from collections import deque

SOURCE_IMAGE = r"C:\Users\ACER\.gemini\antigravity\brain\24cf1964-19cb-471c-8f58-abab7d5e9d16\lucian_assassin_mirrored.jpg"
DEST_FINAL = r"C:\Proyecto HLZ\hlz-port\art\final\sample_batch\hero_lucian_idle.png"
DEST_GODOT = r"C:\Proyecto HLZ\hlz-port\godot\art_samples\hero_lucian_idle.png"

TARGET_CANVAS_W = 128
TARGET_CANVAS_H = 128


def clean_background(img: Image.Image) -> Image.Image:
    """Elimina el fondo blanco usando flood fill desde los bordes para proteger el interior."""
    rgba = img.convert("RGBA")
    w, h = rgba.size
    pixels = np.array(rgba, dtype=np.float32)

    # Identificar píxeles blancos en RGB (distancia a 255)
    r = pixels[:, :, 0]
    g = pixels[:, :, 1]
    b = pixels[:, :, 2]
    
    # Es blanco si los tres canales son muy altos
    is_white = (r > 235) & (g > 235) & (b > 235)

    # Flood fill desde los bordes para encontrar el fondo exterior
    visited = np.zeros((h, w), dtype=bool)
    queue = deque()

    # Agregar todos los bordes que sean casi blancos
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

    # 4-connectivity flood fill
    while queue:
        cy, cx = queue.popleft()
        for dy, dx in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            ny, nx = cy + dy, cx + dx
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx]:
                if is_white[ny, nx]:
                    visited[ny, nx] = True
                    queue.append((ny, nx))

    # Para los píxeles del fondo exterior, calcular alfa suave para evitar aliasing áspero
    alpha = np.ones((h, w), dtype=np.float32) * 255.0
    
    # Los visitados por flood fill tienen alfa = 0 o transición suave
    for y in range(h):
        for x in range(w):
            if visited[y, x]:
                # Calcular qué tan blanco es
                brightness = min(r[y, x], g[y, x], b[y, x])
                if brightness >= 248:
                    alpha[y, x] = 0.0
                elif brightness >= 225:
                    # Transición suave en el borde exterior
                    t = (brightness - 225.0) / (248.0 - 225.0)
                    alpha[y, x] = (1.0 - t) * 255.0
                    # Descontaminar color blanco para no dejar halo claro
                    factor = max(0.1, 1.0 - t)
                    pixels[y, x, 0] = min(255, pixels[y, x, 0] * factor)
                    pixels[y, x, 1] = min(255, pixels[y, x, 1] * factor)
                    pixels[y, x, 2] = min(255, pixels[y, x, 2] * factor)
                else:
                    alpha[y, x] = 0.0

    pixels[:, :, 3] = alpha
    result = Image.fromarray(np.uint8(np.clip(pixels, 0, 255)), mode="RGBA")
    return result


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

    # Queremos que la altura del personaje sea de ~120 px dentro del canvas de 128 px
    target_char_h = 120
    scale = target_char_h / float(crop_h)
    new_w = int(round(crop_w * scale))
    new_h = target_char_h

    resized = cropped.resize((new_w, new_h), Image.Resampling.LANCZOS)

    # Crear canvas transparente
    canvas = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))

    # Centrar horizontalmente, alinear los pies a 4 px del fondo (y=124)
    pos_x = (canvas_w - new_w) // 2
    pos_y = canvas_h - new_h - 4  # 4 px de margen abajo para sombra

    canvas.paste(resized, (pos_x, pos_y), resized)
    return canvas


def main():
    print("=" * 60)
    print("  Procesando Lucian Asesino (Opción 2) para Godot 4")
    print("=" * 60)

    if not os.path.exists(SOURCE_IMAGE):
        print(f"[ERROR] No existe la imagen de origen: {SOURCE_IMAGE}")
        sys.exit(1)

    print(f"1. Cargando imagen origen: {SOURCE_IMAGE}")
    raw_img = Image.open(SOURCE_IMAGE)
    print(f"   Dimensiones originales: {raw_img.size}")

    print("2. Removiendo fondo blanco con flood-fill y antialiasing limpio...")
    clean_img = clean_background(raw_img)

    print(f"3. Ajustando personaje a canvas de {TARGET_CANVAS_W}x{TARGET_CANVAS_H}...")
    final_sprite = crop_and_fit(clean_img, TARGET_CANVAS_W, TARGET_CANVAS_H)

    # Guardar en las dos rutas del proyecto
    os.makedirs(os.path.dirname(DEST_FINAL), exist_ok=True)
    os.makedirs(os.path.dirname(DEST_GODOT), exist_ok=True)

    final_sprite.save(DEST_FINAL, "PNG")
    print(f"   Guardado en: {DEST_FINAL}")

    final_sprite.save(DEST_GODOT, "PNG")
    print(f"   Guardado en: {DEST_GODOT}")

    # Regenerar imports para Godot
    print("4. Regenerando .ctex y .import en Godot...")
    import subprocess
    cmd = [sys.executable, r"C:\Proyecto HLZ\hlz-port\tools\generar_import_godot.py"]
    res = subprocess.run(cmd, capture_output=True, text=True)
    print(res.stdout)
    if res.returncode != 0:
        print("[WARN] Error al regenerar imports:", res.stderr)

    print("[EXITO] Lucian Asesino procesado e integrado exitosamente.")


if __name__ == "__main__":
    main()
