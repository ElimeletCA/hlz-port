import os, glob, json, shutil
from PIL import Image, ImageDraw, ImageFont

ARTIFACT_DIR = r"C:\Users\ACER\.gemini\antigravity\brain\24cf1964-19cb-471c-8f58-abab7d5e9d16"
CAPTURES_DIR = r"c:\Proyecto HLZ\hlz-port\godot\anim_captures"

def main():
    print("Processing real Godot in-engine captures...")
    
    # 1. Copiar captura real de pantalla completa 1080p
    preview_path = os.path.join(CAPTURES_DIR, "godot_actual_render_preview.png")
    dst_1080p = os.path.join(ARTIFACT_DIR, "godot_real_gameplay_1080p.png")
    shutil.copy2(preview_path, dst_1080p)
    print(f"Copied full 1080p real preview to {dst_1080p}")

    # Cargar imagen y generar versión recortada de alta definición enfocada en Lucian
    base_img = Image.open(preview_path)
    w, h = base_img.size
    # Centro en (960, 540). Recortar 600x600 alrededor del personaje y el HUD
    crop_box = (960 - 250, 540 - 280, 960 + 250, 540 + 220)
    cropped_focus = base_img.crop(crop_box)
    dst_focus = os.path.join(ARTIFACT_DIR, "godot_real_lucian_focus.png")
    cropped_focus.save(dst_focus)
    print(f"Saved focused in-engine capture to {dst_focus}")

    # 2. Generar GIF animado continuo de la secuencia real grabada por Godot
    rec_files = sorted(glob.glob(os.path.join(CAPTURES_DIR, "rec_frame_*.png")))
    print(f"Found {len(rec_files)} continuous recording frames.")

    gif_frames = []
    for rf in rec_files:
        with Image.open(rf) as f_img:
            # Recortar en un cuadrado centrado en el sprite para ver cada detalle a 2x
            # El centro de la pantalla es (960, 540). El jugador está en (0, 0)
            c_box = (960 - 180, 540 - 240, 960 + 180, 540 + 120)
            f_cropped = f_img.crop(c_box)
            gif_frames.append(f_cropped.convert("RGBA"))

    if gif_frames:
        # Convertir a modo paleta (P) con transparencia preservada
        gif_paletted = []
        for gf in gif_frames:
            # Cuantizar a 256 colores para GIF nítido
            gif_paletted.append(gf.convert("P", palette=Image.ADAPTIVE))

        gif_dst = os.path.join(ARTIFACT_DIR, "godot_lucian_gameplay_recording.gif")
        gif_paletted[0].save(
            gif_dst,
            save_all=True,
            append_images=gif_paletted[1:],
            duration=int(1000 / 14.0), # 14 FPS canónicos J2ME (71.4 ms)
            loop=0
        )
        print(f"Generated animated recording GIF at 14 FPS: {gif_dst}")

        # Guardar también el ataque combo aislado (frames 8 a 16)
        combo_slice = gif_paletted[8:16]
        if combo_slice:
            combo_gif_dst = os.path.join(ARTIFACT_DIR, "godot_lucian_attack_combo_recording.gif")
            combo_slice[0].save(
                combo_gif_dst,
                save_all=True,
                append_images=combo_slice[1:],
                duration=int(1000 / 14.0),
                loop=0
            )
            print(f"Generated attack combo recording GIF: {combo_gif_dst}")

    # 3. Construir Hoja de Contacto Real in-Engine desde las capturas de Godot
    # Filas:
    # Fila 1: Idle (Down, Up, Left, Right)
    # Fila 2: Walk (Down, Up, Left, Right)
    # Fila 3: Attack Combo 1 Down (F0 a F4)
    # Fila 4: Finisher Combo 2 Down (F0 a F2)
    # Fila 5: Attack Combo 1 Right / Side (F0 a F4)
    
    cell_w, cell_h = 170, 200
    sheet = Image.new("RGBA", (cell_w * 5 + 20, 50 + cell_h * 5 + 40), (14, 17, 23, 255))
    draw = ImageDraw.Draw(sheet)

    # Título
    draw.text((20, 15), "HOJA DE CONTACTO REAL — RENDERIZADA DENTRO DE GODOT 4 (GPU OPENGL)", fill=(255, 215, 60))

    def crop_player_cell(png_path):
        with Image.open(png_path) as im:
            return im.crop((960 - 80, 540 - 150, 960 + 80, 540 + 35))

    dirs = ["down", "up", "left", "right"]

    # Fila 1: Idle 4 dirs
    row_y = 50
    draw.text((20, row_y), "1. REPOSO (IDLE) — 4 DIRECCIONES:", fill=(100, 200, 255))
    for i, d in enumerate(dirs):
        p = os.path.join(CAPTURES_DIR, f"engine_idle_{d}.png")
        if os.path.exists(p):
            cell = crop_player_cell(p)
            sheet.paste(cell, (20 + i * cell_w, row_y + 18))
            draw.text((20 + i * cell_w + 10, row_y + 18 + 165), f"Idle {d.upper()}", fill=(220, 220, 220))

    # Fila 2: Walk 4 dirs
    row_y += cell_h
    draw.text((20, row_y), "2. MARCHA CON ARMAS (WALK) — 4 DIRECCIONES:", fill=(100, 200, 255))
    for i, d in enumerate(dirs):
        p = os.path.join(CAPTURES_DIR, f"engine_walk_{d}.png")
        if os.path.exists(p):
            cell = crop_player_cell(p)
            sheet.paste(cell, (20 + i * cell_w, row_y + 18))
            draw.text((20 + i * cell_w + 10, row_y + 18 + 165), f"Walk {d.upper()}", fill=(220, 220, 220))

    # Fila 3: Attack Combo 1 Down (F0 a F4)
    row_y += cell_h
    draw.text((20, row_y), "3. ATAQUE COMBO 1 SUR (ANIM 6 - TAJOS VFX INTEGRADOS):", fill=(255, 180, 60))
    for f in range(5):
        p = os.path.join(CAPTURES_DIR, f"engine_combo1_down_f{f}.png")
        if os.path.exists(p):
            cell = crop_player_cell(p)
            sheet.paste(cell, (20 + f * cell_w, row_y + 18))
            draw.text((20 + f * cell_w + 10, row_y + 18 + 165), f"Combo1 F{f}", fill=(255, 220, 140))

    # Fila 4: Finisher Combo 2 Down (F0 a F2)
    row_y += cell_h
    draw.text((20, row_y), "4. REMATE COMBO 2 SUR (ANIM 7 - SALTO Y ESTOCADA EN CAIDA):", fill=(255, 120, 120))
    for f in range(3):
        p = os.path.join(CAPTURES_DIR, f"engine_combo2_down_f{f}.png")
        if os.path.exists(p):
            cell = crop_player_cell(p)
            sheet.paste(cell, (20 + f * cell_w, row_y + 18))
            draw.text((20 + f * cell_w + 10, row_y + 18 + 165), f"Finisher F{f}", fill=(255, 160, 160))

    # Fila 5: Attack Combo 1 Right / Side (F0 a F4)
    row_y += cell_h
    draw.text((20, row_y), "5. ATAQUE COMBO 1 PERFIL DERECHO (RIGHT):", fill=(255, 180, 60))
    for f in range(5):
        p = os.path.join(CAPTURES_DIR, f"engine_combo1_right_f{f}.png")
        if os.path.exists(p):
            cell = crop_player_cell(p)
            sheet.paste(cell, (20 + f * cell_w, row_y + 18))
            draw.text((20 + f * cell_w + 10, row_y + 18 + 165), f"Side Atk F{f}", fill=(255, 220, 140))

    sheet_dst = os.path.join(ARTIFACT_DIR, "godot_real_contact_sheet.png")
    sheet.save(sheet_dst)
    print(f"Saved real Godot in-engine contact sheet to {sheet_dst}")

if __name__ == "__main__":
    main()
