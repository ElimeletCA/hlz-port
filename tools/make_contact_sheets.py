"""
tools/make_contact_sheets.py — Generador de hojas de contacto (Contact Sheets) de sprites (T2.7).
Organiza los 3.199 sprites extraídos en hojas de cuadrícula etiquetadas por categoría:
  1. Héroe (Lucian por clases 0..4 y armas)
  2. Enemigos y Jefes (en/0..53)
  3. Habilidades y Efectos Especiales (s/0..10)
  4. Objetos y Elementos de Escenario (m/ob0..ob4)
  5. Iconos e Interfaz (img/)
"""

import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

REPO_ROOT = Path(__file__).resolve().parent.parent
SPRITES_DIR = REPO_ROOT / "out" / "sprites"
SHEETS_DIR = REPO_ROOT / "out" / "contact_sheets"


def create_contact_sheet(
    image_paths: list,
    output_path: Path,
    title: str = "",
    columns: int = 16,
    cell_size: int = 48,
    bg_color=(28, 32, 38, 255)
):
    """Genera una hoja de contacto en cuadrícula con bordes y centrado de sprites."""
    if not image_paths:
        return None

    count = len(image_paths)
    cols = min(columns, count)
    rows = math.ceil(count / cols)

    header_height = 36 if title else 8
    padding = 4
    sheet_w = cols * (cell_size + padding) + padding
    sheet_h = header_height + rows * (cell_size + padding) + padding

    sheet = Image.new("RGBA", (sheet_w, sheet_h), bg_color)
    draw = ImageDraw.Draw(sheet)

    if title:
        draw.text((padding + 4, 8), title, fill=(220, 230, 242))

    for i, path in enumerate(image_paths):
        c = i % cols
        r = i // cols
        x = padding + c * (cell_size + padding)
        y = header_height + r * (cell_size + padding)

        # Marco de casilla
        draw.rectangle([x, y, x + cell_size - 1, y + cell_size - 1], outline=(45, 52, 64), fill=(38, 44, 54))

        try:
            with Image.open(path) as img:
                img_rgba = img.convert("RGBA")
                iw, ih = img_rgba.size
                
                # Ajustar manteniendo proporción si excede el tamaño de celda
                max_dim = cell_size - 6
                if iw > max_dim or ih > max_dim:
                    scale = min(max_dim / iw, max_dim / ih)
                    new_w = max(1, int(iw * scale))
                    new_h = max(1, int(ih * scale))
                    img_rgba = img_rgba.resize((new_w, new_h), Image.NEAREST)
                    iw, ih = new_w, new_h

                paste_x = x + (cell_size - iw) // 2
                paste_y = y + (cell_size - ih) // 2
                sheet.paste(img_rgba, (paste_x, paste_y), img_rgba)
        except Exception:
            pass

    output_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output_path, "PNG")
    return output_path


def generate_all_contact_sheets():
    SHEETS_DIR.mkdir(parents=True, exist_ok=True)
    print("=== Generando Hojas de Contacto de Sprites Originales ===")

    # 1. Héroe y armas
    hero_sprites = sorted((SPRITES_DIR / "hero").rglob("*.png"))
    if hero_sprites:
        out = create_contact_sheet(
            hero_sprites,
            SHEETS_DIR / "contact_hero_and_weapons.png",
            title=f"Heroes Lore: Zero — Lucian (Clases y Armas) [{len(hero_sprites)} frames]",
            columns=20,
            cell_size=40
        )
        print(f"  [OK] Héroe y armas: {len(hero_sprites)} frames -> {out.name}")

    # 2. Enemigos por familias (para legibilidad se dividen en 2 hojas si son muchos)
    en_sprites = sorted((SPRITES_DIR / "en").rglob("*.png"))
    if en_sprites:
        # Primera mitad
        mid = len(en_sprites) // 2
        out1 = create_contact_sheet(
            en_sprites[:mid],
            SHEETS_DIR / "contact_enemies_part1.png",
            title=f"Heroes Lore: Zero — Enemigos y Jefes (Parte 1) [{mid} frames]",
            columns=24,
            cell_size=36
        )
        out2 = create_contact_sheet(
            en_sprites[mid:],
            SHEETS_DIR / "contact_enemies_part2.png",
            title=f"Heroes Lore: Zero — Enemigos y Jefes (Parte 2) [{len(en_sprites)-mid} frames]",
            columns=24,
            cell_size=36
        )
        print(f"  [OK] Enemigos y jefes: {len(en_sprites)} frames -> {out1.name}, {out2.name}")

    # 3. Habilidades y efectos (s/)
    s_sprites = sorted((SPRITES_DIR / "s").rglob("*.png"))
    if s_sprites:
        out = create_contact_sheet(
            s_sprites,
            SHEETS_DIR / "contact_skills_vfx.png",
            title=f"Heroes Lore: Zero — Habilidades y VFX [{len(s_sprites)} frames]",
            columns=20,
            cell_size=40
        )
        print(f"  [OK] Habilidades y VFX: {len(s_sprites)} frames -> {out.name}")

    # 4. Objetos y props de mapa (m/ob*)
    ob_sprites = sorted((SPRITES_DIR / "m").glob("ob*/*.png"))
    if ob_sprites:
        out = create_contact_sheet(
            ob_sprites,
            SHEETS_DIR / "contact_map_objects.png",
            title=f"Heroes Lore: Zero — Objetos y Props de Mapa [{len(ob_sprites)} frames]",
            columns=18,
            cell_size=40
        )
        print(f"  [OK] Objetos de mapa: {len(ob_sprites)} frames -> {out.name}")

    # 5. Iconos e interfaz (img/)
    ui_sprites = sorted((SPRITES_DIR / "img").rglob("*.png"))
    if ui_sprites:
        out = create_contact_sheet(
            ui_sprites,
            SHEETS_DIR / "contact_ui_icons.png",
            title=f"Heroes Lore: Zero — Iconos e Interfaz [{len(ui_sprites)} frames]",
            columns=20,
            cell_size=36
        )
        print(f"  [OK] Iconos e UI: {len(ui_sprites)} frames -> {out.name}")

    print("[EXITO] Todas las hojas de contacto generadas en out/contact_sheets/")


if __name__ == "__main__":
    generate_all_contact_sheets()
