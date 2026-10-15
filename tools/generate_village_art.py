"""
tools/generate_village_art.py — Generador de arte ilustrado para la Aldea (T5.10 / T5.11).
Genera los elementos visuales de la Aldea Silverleaf según art/STYLE.md:
  1. map_silverleaf.png: Terreno ilustrado completo de 1792x2560 px (senderos de adoquines, hierba orgánica, iluminación dorada).
  2. prop_village_house.png: Fachada de casa rústica de aldea con tejas rojas y vigas de roble para Y-Sort.
  3. prop_cottage.png: Cabaña/taller del entrenador con toldo de lona y farol.
  4. prop_fence.png: Cerca de madera rústica para caminos.
  5. prop_lantern.png: Farol de hierro con resplandor cálido.
  6. prop_barrel.png: Barril de madera y cajas de provisiones.
"""

import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

REPO_ROOT = Path(__file__).resolve().parent.parent
ART_FINAL = REPO_ROOT / "art" / "final" / "sample_batch"
GODOT_ASSETS = REPO_ROOT / "godot" / "art_samples"


def generate_village_terrain() -> Image.Image:
    """Genera el terreno ilustrado de Aldea Silverleaf (1792x2560 px) respetando la planta canónica."""
    w, h = 1792, 2560
    base = Image.new("RGBA", (w, h), (46, 88, 42, 255)) # Verde hierba campestre
    draw = ImageDraw.Draw(base)

    # 1. Variaciones orgánicas de hierba y claros
    for y in range(0, h, 64):
        for x in range(0, w, 64):
            # Patrón de ruido determinista suave
            v = int(math.sin(x * 0.015) * math.cos(y * 0.015) * 18)
            g = max(30, min(105, 88 + v))
            r = max(25, min(65, 46 + v // 2))
            b = max(20, min(55, 42 + v // 3))
            draw.rectangle([x, y, x + 64, y + 64], fill=(r, g, b, 255))

    # Pinceladas de tréboles y musgo
    for i in range(1200):
        px = (i * 137) % w
        py = (i * 263) % h
        r_size = ((i % 5) + 3) * 4
        tone = 95 + (i % 25)
        draw.ellipse([px, py, px + r_size, py + r_size // 2], fill=(tone - 40, tone, tone - 45, 160))

    # 2. Caminos principales de adoquines y tierra desgastada
    # Plaza central (alrededor de 896, 1280)
    draw.ellipse([700, 1080, 1100, 1480], fill=(168, 145, 120, 255))
    draw.ellipse([740, 1120, 1060, 1440], fill=(182, 160, 134, 255))

    # Sendero Norte a Sur
    draw.polygon([(840, 0), (960, 0), (990, 1150), (810, 1150)], fill=(175, 152, 126, 255))
    draw.polygon([(820, 1420), (980, 1420), (950, 2560), (830, 2560)], fill=(175, 152, 126, 255))

    # Sendero Este a Oeste
    draw.polygon([(0, 1220), (750, 1200), (750, 1360), (0, 1340)], fill=(170, 148, 122, 255))
    draw.polygon([(1050, 1200), (1792, 1220), (1792, 1340), (1050, 1360)], fill=(170, 148, 122, 255))

    # Ramal hacia el orfanato (suroeste)
    draw.polygon([(780, 1320), (880, 1350), (450, 1850), (370, 1800)], fill=(165, 142, 118, 255))
    # Ramal hacia la herrería (noreste)
    draw.polygon([(960, 1210), (1050, 1240), (1450, 850), (1370, 810)], fill=(165, 142, 118, 255))

    # 3. Textura de adoquines desgastados en la plaza y senderos
    for step in range(3000):
        ax = (step * 73) % w
        ay = (step * 109) % h
        col = base.getpixel((ax, ay))
        # Solo aplicar adoquines sobre áreas terrosas
        if col[0] > 140 and col[1] > 120:
            aw = ((step % 4) + 2) * 5
            ah = ((step % 3) + 2) * 4
            edge_col = (max(0, col[0] - 25), max(0, col[1] - 25), max(0, col[2] - 25), 200)
            center_col = (min(255, col[0] + 15), min(255, col[1] + 15), min(255, col[2] + 15), 230)
            draw.rounded_rectangle([ax, ay, ax + aw, ay + ah], radius=2, fill=center_col, outline=edge_col)

    # 4. Bordes de vegetación y transición suave (suavizado gaussiano en máscara)
    # 5. Iluminación dorada ambiental difusa (atmósfera matutina Silverleaf)
    gold_wash = Image.new("RGBA", (w, h), (255, 230, 170, 28))
    base = Image.alpha_composite(base, gold_wash)

    # Viñeta suave en los márgenes exteriores para focalizar la aldea
    vignette = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    vdraw = ImageDraw.Draw(vignette)
    vdraw.rectangle([0, 0, w, 60], fill=(15, 22, 18, 140))
    vdraw.rectangle([0, h - 60, w, h], fill=(15, 22, 18, 140))
    vdraw.rectangle([0, 0, 60, h], fill=(15, 22, 18, 140))
    vdraw.rectangle([w - 60, 0, w, h], fill=(15, 22, 18, 140))
    base = Image.alpha_composite(base, vignette)

    return base


def create_village_house() -> Image.Image:
    """Genera una fachada de casa de aldea ilustrada (256x256 px) preparada para Y-Sort."""
    w, h = 256, 256
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Sombra de contacto en la base del suelo
    draw.ellipse([16, 230, 240, 252], fill=(12, 16, 20, 130))

    # 2. Muros de piedra y mortero (base)
    # y=120 a 240
    draw.rectangle([32, 120, 224, 240], fill=(155, 145, 135, 255), outline=(95, 85, 75, 255), width=3)
    # Bloques de piedra individuales dibujados
    for y in range(124, 236, 20):
        offset = 12 if (y // 20) % 2 == 1 else 0
        for x in range(36 + offset, 220, 28):
            draw.rounded_rectangle([x, y, min(220, x + 24), y + 16], radius=2,
                                   fill=(170, 160, 150, 255), outline=(125, 115, 105, 255))

    # 3. Vigas maestras de roble oscuro (esquinas y dintel)
    draw.rectangle([30, 116, 42, 240], fill=(85, 52, 30, 255), outline=(50, 30, 16, 255))
    draw.rectangle([214, 116, 226, 240], fill=(85, 52, 30, 255), outline=(50, 30, 16, 255))
    draw.rectangle([30, 116, 226, 128], fill=(85, 52, 30, 255), outline=(50, 30, 16, 255))

    # 4. Puerta de roble arqueada con clavos de forja
    draw.rounded_rectangle([108, 162, 148, 240], radius=8, fill=(105, 62, 34, 255), outline=(55, 32, 18, 255), width=2)
    # Manija dorada y ventanuco
    draw.ellipse([140, 200, 144, 204], fill=(220, 180, 50, 255))
    draw.rounded_rectangle([120, 172, 136, 188], radius=3, fill=(40, 75, 110, 255), outline=(55, 32, 18, 255))

    # 5. Ventanas con luz cálida interior
    # Ventana izquierda
    draw.rounded_rectangle([56, 150, 88, 190], radius=4, fill=(255, 215, 120, 255), outline=(75, 45, 25, 255), width=3)
    draw.line([(72, 150), (72, 190)], fill=(75, 45, 25, 255), width=2)
    draw.line([(56, 170), (88, 170)], fill=(75, 45, 25, 255), width=2)
    # Ventana derecha
    draw.rounded_rectangle([168, 150, 200, 190], radius=4, fill=(255, 215, 120, 255), outline=(75, 45, 25, 255), width=3)
    draw.line([(184, 150), (184, 190)], fill=(75, 45, 25, 255), width=2)
    draw.line([(168, 170), (200, 170)], fill=(75, 45, 25, 255), width=2)

    # 6. Chimenea de piedra en el lado derecho con humo
    draw.rectangle([190, 20, 216, 80], fill=(130, 120, 115, 255), outline=(80, 70, 65, 255), width=2)
    draw.rectangle([186, 16, 220, 24], fill=(95, 85, 80, 255))

    # 7. Tejado a dos aguas de tejas rojas rústicas (Gable roof)
    # Coordenadas del triángulo del tejado
    roof = [(128, 30), (248, 124), (8, 124)]
    draw.polygon(roof, fill=(185, 65, 45, 255), outline=(115, 35, 20, 255))
    # Capas de tejas con gradiente y sombras
    for row in range(38, 124, 10):
        inset = int((row - 30) * 1.25)
        lx = max(10, 128 - inset)
        rx = min(246, 128 + inset)
        shade = 195 - (row // 4)
        draw.line([(lx, row), (rx, row)], fill=(shade, 55, 35, 255), width=3)

    # Cumbrera de madera tallada en la punta
    draw.polygon([(128, 20), (136, 32), (120, 32)], fill=(110, 70, 40, 255))

    return img


def create_trainer_cottage() -> Image.Image:
    """Genera la cabaña y puesto de entrenamiento de Aldren (256x220 px)."""
    w, h = 256, 220
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Sombra
    draw.ellipse([16, 196, 240, 216], fill=(12, 16, 20, 130))

    # Estructura de cabaña de madera rústica
    draw.rectangle([36, 90, 220, 206], fill=(115, 78, 48, 255), outline=(65, 40, 22, 255), width=3)
    for y in range(98, 204, 14):
        draw.line([(38, y), (218, y)], fill=(85, 52, 28, 255), width=2)

    # Puerta amplia de granero/taller
    draw.rectangle([98, 130, 158, 206], fill=(80, 50, 30, 255), outline=(48, 28, 15, 255), width=2)
    # Refuerzos diagonales en 'X'
    draw.line([(100, 132), (156, 204)], fill=(120, 80, 50, 255), width=3)
    draw.line([(100, 204), (156, 132)], fill=(120, 80, 50, 255), width=3)

    # Tejado de tejas azuladas/pizarra
    roof = [(128, 15), (246, 94), (10, 94)]
    draw.polygon(roof, fill=(65, 82, 110, 255), outline=(38, 48, 68, 255))
    for row in range(22, 94, 8):
        inset = int((row - 15) * 1.35)
        lx = max(12, 128 - inset)
        rx = min(244, 128 + inset)
        draw.line([(lx, row), (rx, row)], fill=(50, 66, 92, 255), width=2)

    # Toldo exterior para entrenamiento de armas (lado izquierdo)
    draw.polygon([(36, 120), (90, 135), (84, 145), (36, 130)], fill=(195, 175, 140, 255), outline=(120, 100, 75, 255))
    # Poste de soporte del toldo
    draw.line([(88, 138), (88, 206)], fill=(90, 55, 30, 255), width=3)

    # Diana de tiro y maniquí de paja junto a la cabaña
    draw.ellipse([180, 140, 204, 164], fill=(225, 200, 150, 255), outline=(140, 90, 40, 255), width=2)
    draw.ellipse([186, 146, 198, 158], fill=(195, 45, 35, 255))
    draw.ellipse([190, 150, 194, 154], fill=(245, 235, 210, 255))
    draw.line([(192, 164), (192, 206)], fill=(95, 60, 35, 255), width=3)

    return img


def create_fence_sprite() -> Image.Image:
    """Genera cerca de madera rústica (96x48 px)."""
    img = Image.new("RGBA", (96, 48), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Sombra
    draw.ellipse([4, 40, 92, 46], fill=(12, 16, 20, 90))

    # Postes verticales
    for px in [12, 48, 84]:
        draw.polygon([(px - 4, 10), (px, 4), (px + 4, 10), (px + 4, 44), (px - 4, 44)],
                     fill=(125, 85, 50, 255), outline=(75, 48, 25, 255))

    # Tablones horizontales
    draw.rectangle([4, 16, 92, 23], fill=(140, 95, 58, 255), outline=(85, 55, 30, 255))
    draw.rectangle([4, 28, 92, 35], fill=(130, 88, 52, 255), outline=(85, 55, 30, 255))

    return img


def create_lantern_sprite() -> Image.Image:
    """Genera farol de hierro de la aldea con poste y resplandor (48x80 px)."""
    img = Image.new("RGBA", (48, 80), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Sombra
    draw.ellipse([14, 72, 34, 78], fill=(12, 16, 20, 100))

    # Poste de hierro forjado
    draw.rectangle([22, 28, 26, 75], fill=(45, 50, 58, 255))
    draw.rectangle([18, 72, 30, 76], fill=(55, 60, 70, 255))

    # Brazo curvado
    draw.arc([14, 14, 34, 34], start=180, end=360, fill=(45, 50, 58, 255), width=3)

    # Farol con cristal y vela
    draw.rectangle([18, 18, 30, 32], fill=(255, 230, 140, 240), outline=(35, 40, 48, 255), width=2)
    # Caperuza superior
    draw.polygon([(16, 18), (24, 10), (32, 18)], fill=(45, 50, 58, 255))
    # Llama cálida interior
    draw.ellipse([22, 22, 26, 28], fill=(255, 140, 20, 255))

    return img


def create_barrel_stack() -> Image.Image:
    """Genera barril y cajas de suministros de la aldea (64x64 px)."""
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Sombra
    draw.ellipse([6, 52, 58, 62], fill=(12, 16, 20, 110))

    # Caja de madera izquierda
    draw.rounded_rectangle([8, 28, 32, 56], radius=2, fill=(145, 100, 60, 255), outline=(85, 55, 30, 255), width=2)
    draw.line([(8, 28), (32, 56)], fill=(105, 70, 40, 255), width=2)
    draw.line([(8, 56), (32, 28)], fill=(105, 70, 40, 255), width=2)

    # Barril de roble a la derecha
    draw.ellipse([32, 20, 58, 58], fill=(125, 80, 45, 255), outline=(75, 45, 24, 255), width=2)
    # Aros de hierro
    draw.arc([32, 26, 58, 34], start=0, end=180, fill=(65, 72, 82, 255), width=3)
    draw.arc([32, 44, 58, 52], start=0, end=180, fill=(65, 72, 82, 255), width=3)
    # Tapa superior
    draw.ellipse([36, 20, 54, 28], fill=(105, 65, 35, 255))

    return img


def create_trainer_npc_sprite() -> Image.Image:
    """Genera sprite ilustrado del Maestro de Armas Aldren (96x128 px)."""
    img = Image.new("RGBA", (96, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Sombra elíptica
    draw.ellipse([22, 114, 74, 126], fill=(12, 16, 20, 110))

    # 2. Piernas y botas de explorador
    draw.rounded_rectangle([36, 76, 60, 116], radius=4, fill=(50, 42, 36, 255))
    draw.rounded_rectangle([34, 102, 46, 118], radius=2, fill=(65, 45, 30, 255))
    draw.rounded_rectangle([50, 102, 62, 118], radius=2, fill=(65, 45, 30, 255))

    # 3. Túnica verde bosque y jubón de cuero marrón
    draw.rounded_rectangle([30, 42, 66, 80], radius=5, fill=(45, 68, 50, 255))
    draw.rectangle([34, 46, 62, 78], fill=(88, 58, 36, 255), outline=(55, 35, 20, 255))
    # Cinturón con remaches
    draw.rectangle([30, 74, 66, 80], fill=(42, 28, 18, 255))
    draw.rectangle([44, 73, 52, 81], fill=(195, 150, 50, 255))

    # 4. Brazos cruzados con brazaletes de cuero
    draw.rounded_rectangle([22, 50, 74, 70], radius=4, fill=(80, 52, 32, 255), outline=(50, 32, 18, 255))

    # 5. Rostro veterano con barba y cabello grisáceo
    draw.ellipse([36, 20, 60, 46], fill=(240, 205, 175, 255))
    # Barba y bigote gris
    draw.polygon([(36, 36), (48, 48), (60, 36), (56, 32), (40, 32)], fill=(185, 185, 190, 255))
    # Ojos determinados
    draw.rectangle([41, 28, 44, 30], fill=(40, 30, 20, 255))
    draw.rectangle([52, 28, 55, 30], fill=(40, 30, 20, 255))
    # Cabello gris hacia atrás
    draw.polygon([(34, 24), (32, 16), (40, 10), (48, 8), (56, 10), (64, 16), (62, 24), (54, 14), (42, 14)],
                 fill=(195, 195, 200, 255))

    # 6. Espada de entrenamiento en la cadera
    draw.line([(66, 68), (76, 92)], fill=(160, 160, 170, 255), width=3)
    draw.ellipse([64, 66, 68, 70], fill=(195, 150, 50, 255))

    return img


def main():
    print("=== Generando Activos de Arte Ilustrado para la Aldea (T5.10 / T5.11) ===")
    ART_FINAL.mkdir(parents=True, exist_ok=True)
    GODOT_ASSETS.mkdir(parents=True, exist_ok=True)

    assets = {
        "map_silverleaf.png": generate_village_terrain(),
        "prop_village_house.png": create_village_house(),
        "prop_cottage.png": create_trainer_cottage(),
        "prop_fence.png": create_fence_sprite(),
        "prop_lantern.png": create_lantern_sprite(),
        "prop_barrel.png": create_barrel_stack(),
        "npc_aldren.png": create_trainer_npc_sprite(),
    }

    for name, img in assets.items():
        # Guardar en art/final/sample_batch/
        p_art = ART_FINAL / name
        img.save(p_art, "PNG")
        # Guardar en godot/art_samples/
        p_godot = GODOT_ASSETS / name
        img.save(p_godot, "PNG")
        print(f"  [OK] {name:24s} -> {img.size[0]}x{img.size[1]} px, RGBA")

    print("[ÉXITO] Todos los activos ilustrados de la Aldea fueron generados e instalados.")


if __name__ == "__main__":
    main()
