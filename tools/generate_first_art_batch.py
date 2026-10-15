"""
tools/generate_first_art_batch.py — Generador del primer lote de arte 2D estilizado (T4.8).
Crea los activos clave de muestra conforme a la biblia visual art/STYLE.md:
  1. Héroe Lucian (96x128 px, pelo rojo ardiente, armadura azul y hombreras doradas).
  2. Enemigo Lobo de bosque (80x64 px, pelaje gris-azulado, ojos ámbar).
  3. Tile de suelo hierba/sendero (64x64 px, paleta verde musgo y tierra natural).
  4. Obstáculo árbol ancestral (128x160 px, follaje por capas para Y-Sort).
  5. Cofre de tesoro cerrado y abierto (48x48 px, madera y refuerzos de bronce).
  6. Efecto VFX de tajo de espada (96x64 px, estela de energía cian con núcleo brillante).
"""

import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

REPO_ROOT = Path(__file__).resolve().parent.parent
ART_FINAL = REPO_ROOT / "art" / "final" / "sample_batch"
GODOT_ASSETS = REPO_ROOT / "godot" / "art_samples"


def create_hero_sprite() -> Image.Image:
    """Genera sprite ilustrado de Lucian (96x128 px) con capas pintadas y sombra elíptica."""
    img = Image.new("RGBA", (96, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Sombra de contacto en el suelo
    draw.ellipse([24, 114, 72, 126], fill=(12, 16, 20, 110))

    # 2. Capa base y piernas (armadura azul metálico oscuro)
    draw.rounded_rectangle([38, 76, 58, 116], radius=4, fill=(28, 42, 65, 255), outline=(18, 28, 44, 255))
    # Botas de cuero reforzado
    draw.rounded_rectangle([36, 104, 46, 118], radius=2, fill=(45, 32, 22, 255))
    draw.rounded_rectangle([50, 104, 60, 118], radius=2, fill=(45, 32, 22, 255))

    # 3. Torso y pechera (azul noble con ribetes dorados)
    draw.rounded_rectangle([32, 42, 64, 80], radius=6, fill=(35, 58, 92, 255), outline=(212, 175, 55, 255), width=2)
    # Cinturón con hebilla de bronce
    draw.rectangle([32, 74, 64, 80], fill=(55, 38, 25, 255))
    draw.rectangle([44, 73, 52, 81], fill=(225, 185, 65, 255))

    # 4. Hombreras doradas pesadas (Guerrero)
    draw.ellipse([22, 40, 36, 56], fill=(218, 165, 32, 255), outline=(160, 120, 20, 255))
    draw.ellipse([60, 40, 74, 56], fill=(218, 165, 32, 255), outline=(160, 120, 20, 255))

    # 5. Brazos y guanteletes
    draw.rounded_rectangle([22, 54, 30, 82], radius=3, fill=(32, 48, 75, 255))
    draw.rounded_rectangle([66, 54, 74, 82], radius=3, fill=(32, 48, 75, 255))

    # 6. Cabeza y rostro (tono piel cálido)
    draw.ellipse([36, 20, 60, 46], fill=(250, 220, 195, 255))
    # Ojos y expresión decidida
    draw.rectangle([42, 32, 45, 35], fill=(30, 60, 100, 255))
    draw.rectangle([51, 32, 54, 35], fill=(30, 60, 100, 255))

    # 7. Cabello rojo fuego característico de Lucian
    hair_points = [
        (34, 26), (30, 18), (36, 12), (44, 6), (52, 8),
        (60, 12), (66, 18), (62, 26), (56, 16), (48, 14), (40, 18)
    ]
    draw.polygon(hair_points, fill=(210, 45, 25, 255), outline=(150, 25, 10, 255))
    # Mechones frontales
    draw.polygon([(36, 22), (40, 30), (43, 24)], fill=(225, 55, 30, 255))
    draw.polygon([(46, 20), (48, 28), (51, 22)], fill=(235, 75, 45, 255))

    # 8. Empuñadura de mandoble en la espalda
    draw.rectangle([62, 22, 66, 50], fill=(180, 140, 30, 255))
    draw.rectangle([58, 28, 70, 32], fill=(220, 180, 45, 255)) # Guarda dorada

    return img


def create_enemy_sprite() -> Image.Image:
    """Genera sprite de bestia / lobo de bosque (80x64 px)."""
    img = Image.new("RGBA", (80, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Sombra
    draw.ellipse([14, 52, 66, 62], fill=(12, 16, 20, 95))

    # Cuerpo (pelaje gris azulado oscuro)
    draw.ellipse([20, 24, 60, 52], fill=(55, 62, 72, 255), outline=(38, 44, 52, 255))

    # Patas
    draw.rectangle([22, 44, 28, 56], fill=(42, 48, 56, 255))
    draw.rectangle([34, 44, 40, 56], fill=(42, 48, 56, 255))
    draw.rectangle([48, 44, 54, 56], fill=(42, 48, 56, 255))
    draw.rectangle([56, 44, 62, 56], fill=(42, 48, 56, 255))

    # Cabeza y hocico orientado hacia la izquierda
    draw.ellipse([12, 18, 36, 40], fill=(62, 70, 82, 255))
    draw.polygon([(10, 28), (14, 38), (4, 34)], fill=(48, 54, 64, 255)) # Hocico

    # Orejas puntiagudas
    draw.polygon([(20, 18), (26, 8), (28, 20)], fill=(75, 82, 95, 255))
    draw.polygon([(28, 18), (34, 10), (36, 20)], fill=(55, 62, 72, 255))

    # Ojos ámbar brillantes
    draw.ellipse([16, 24, 20, 28], fill=(255, 180, 20, 255))

    # Cola erizada
    draw.polygon([(56, 30), (74, 24), (66, 40)], fill=(50, 56, 65, 255))

    return img


def create_tile_sprite() -> Image.Image:
    """Genera tile de suelo estilizado pintado (64x64 px)."""
    img = Image.new("RGBA", (64, 64), (45, 90, 40, 255)) # Verde base
    draw = ImageDraw.Draw(img)

    # Pinceladas de musgo y variaciones
    draw.rectangle([4, 4, 32, 28], fill=(52, 105, 46, 255))
    draw.rectangle([30, 24, 60, 58], fill=(38, 80, 34, 255))
    draw.ellipse([12, 38, 28, 54], fill=(60, 118, 52, 255))

    # Borde sutil de tierra compacta
    draw.line([(0, 63), (63, 63)], fill=(32, 65, 28, 255), width=2)
    draw.line([(63, 0), (63, 63)], fill=(32, 65, 28, 255), width=2)

    return img


def create_prop_tree() -> Image.Image:
    """Genera obstáculo de entorno: Árbol ancestral estilizado (128x160 px)."""
    img = Image.new("RGBA", (128, 160), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Sombra proyectada amplia
    draw.ellipse([16, 138, 112, 158], fill=(10, 14, 18, 120))

    # Tronco nudoso y raíces
    trunk = [(54, 80), (74, 80), (82, 145), (46, 145)]
    draw.polygon(trunk, fill=(68, 48, 32, 255), outline=(45, 30, 18, 255))
    draw.polygon([(46, 140), (32, 150), (52, 145)], fill=(55, 38, 24, 255)) # Raíz izq
    draw.polygon([(76, 140), (96, 150), (72, 145)], fill=(55, 38, 24, 255)) # Raíz der

    # Follaje en capas pintadas (Profundidad por sombras)
    draw.ellipse([18, 42, 110, 110], fill=(32, 72, 35, 255)) # Capa oscura trasera
    draw.ellipse([26, 24, 102, 92], fill=(42, 98, 46, 255))   # Capa media
    draw.ellipse([36, 10, 92, 70], fill=(58, 128, 62, 255))   # Capa superior con luz
    draw.ellipse([50, 16, 78, 46], fill=(75, 152, 78, 255))   # Brillo cenital

    return img


def create_chest_sprites() -> tuple:
    """Genera cofre de tesoro cerrado y abierto (48x48 px)."""
    # 1. Cerrado
    c_img = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    c_draw = ImageDraw.Draw(c_img)
    c_draw.ellipse([6, 38, 42, 46], fill=(12, 16, 20, 100)) # Sombra
    c_draw.rounded_rectangle([8, 16, 40, 42], radius=4, fill=(110, 68, 38, 255), outline=(60, 35, 18, 255), width=2)
    # Refuerzos de bronce
    c_draw.rectangle([8, 26, 40, 30], fill=(185, 140, 45, 255))
    c_draw.rectangle([21, 24, 27, 32], fill=(225, 180, 60, 255)) # Cerradura

    # 2. Abierto
    o_img = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    o_draw = ImageDraw.Draw(o_img)
    o_draw.ellipse([6, 38, 42, 46], fill=(12, 16, 20, 100))
    # Caja base abierta
    o_draw.rounded_rectangle([8, 22, 40, 42], radius=3, fill=(90, 52, 28, 255), outline=(50, 28, 14, 255), width=2)
    # Oro resplandeciente en el interior
    o_draw.ellipse([12, 22, 36, 32], fill=(245, 200, 50, 255))
    # Tapa levantada
    o_draw.rounded_rectangle([8, 8, 40, 22], radius=3, fill=(115, 72, 40, 255), outline=(60, 35, 18, 255), width=2)
    o_draw.rectangle([21, 14, 27, 18], fill=(185, 140, 45, 255))

    return c_img, o_img


def create_slash_vfx() -> Image.Image:
    """Genera efecto visual de tajo de espada (96x64 px)."""
    img = Image.new("RGBA", (96, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Arco exterior de energía cian
    draw.arc([10, 8, 86, 56], start=160, end=350, fill=(0, 210, 255, 180), width=8)
    # Núcleo blanco brillante intenso
    draw.arc([12, 10, 84, 54], start=170, end=340, fill=(240, 255, 255, 255), width=3)
    # Destellos en las puntas
    draw.ellipse([14, 38, 20, 44], fill=(180, 245, 255, 220))
    draw.ellipse([78, 12, 84, 18], fill=(180, 245, 255, 220))

    return img


def generate_all_samples():
    ART_FINAL.mkdir(parents=True, exist_ok=True)
    GODOT_ASSETS.mkdir(parents=True, exist_ok=True)
    print("=== Generando Primer Lote de Arte 2D Estilizado (T4.8) ===")

    assets = {
        "hero_lucian_idle.png": create_hero_sprite(),
        "enemy_forest_wolf.png": create_enemy_sprite(),
        "tile_grass_base.png": create_tile_sprite(),
        "prop_ancient_tree.png": create_prop_tree(),
        "vfx_sword_slash.png": create_slash_vfx()
    }

    c_chest, o_chest = create_chest_sprites()
    assets["prop_chest_closed.png"] = c_chest
    assets["prop_chest_open.png"] = o_chest

    for name, img in assets.items():
        # Guardar en art/final/sample_batch/
        p_art = ART_FINAL / name
        img.save(p_art, "PNG")
        # Copiar a godot/art_samples/
        p_godot = GODOT_ASSETS / name
        img.save(p_godot, "PNG")
        print(f"  [OK] Generado: {name:25s} ({img.size[0]}x{img.size[1]} px, RGBA)")

    print("[EXITO] Lote inicial generado y copiado a godot/art_samples/")


if __name__ == "__main__":
    generate_all_samples()
