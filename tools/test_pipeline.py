"""
tools/test_pipeline.py — Validación técnica del pipeline de importación de arte 2D en Godot (T0.5).
Genera activos de prueba con canal alfa (transparencia), un spritesheet y un tilesheet,
y valida su importación y visualización en Godot 4.
"""

from pathlib import Path
from PIL import Image, ImageDraw
import subprocess
import sys

REPO_ROOT = Path(__file__).resolve().parent.parent
GODOT_DIR = REPO_ROOT / "godot"
ASSETS_DIR = GODOT_DIR / "test_assets"
GODOT_CON = Path(r"C:\Proyecto HLZ\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe")


def create_test_sprite(path: Path):
    """Crea un sprite de prueba 128x128 con canal alfa transparente y gradiente simple."""
    img = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Círculo exterior (sombra/halo)
    draw.ellipse([8, 8, 120, 120], fill=(40, 80, 160, 220), outline=(200, 220, 255, 255), width=3)
    # Núcleo interior
    draw.rectangle([36, 36, 92, 92], fill=(220, 180, 70, 240), outline=(255, 240, 150, 255), width=2)
    # Detalles
    draw.polygon([(64, 44), (84, 84), (44, 84)], fill=(240, 70, 70, 255))
    img.save(path, format="PNG")
    print(f"  [OK] Creado sprite con transparencia: {path} ({path.stat().st_size} bytes)")


def create_test_spritesheet(path: Path):
    """Crea un spritesheet de prueba 256x64 (4 frames de 64x64) con canal alfa."""
    img = Image.new("RGBA", (256, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    for i in range(4):
        x_offset = i * 64
        # Fondo del frame (transparente)
        # Personaje / forma básica con variación por frame para simular movimiento
        bounce_y = (i % 2) * 4
        # Sombra en suelo
        draw.ellipse([x_offset + 16, 52, x_offset + 48, 60], fill=(0, 0, 0, 80))
        # Cuerpo
        draw.rectangle([x_offset + 20, 20 - bounce_y, x_offset + 44, 52 - bounce_y], fill=(70, 140, 210, 255))
        # Cabeza
        draw.ellipse([x_offset + 22, 8 - bounce_y, x_offset + 42, 26 - bounce_y], fill=(240, 200, 150, 255))
        # Indicador de frame
        draw.rectangle([x_offset + 28, 30 - bounce_y, x_offset + 36, 38 - bounce_y], fill=(255, 255, 255, 255))
    img.save(path, format="PNG")
    print(f"  [OK] Creado spritesheet (4 frames 64x64): {path} ({path.stat().st_size} bytes)")


def create_test_tilesheet(path: Path):
    """Crea un tilesheet de prueba 128x128 (cuadrícula 2x2 tiles de 64x64) con canal alfa."""
    img = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Tile (0,0): Suelo base hierba
    draw.rectangle([0, 0, 63, 63], fill=(68, 128, 62, 255), outline=(50, 95, 45, 255))
    draw.rectangle([12, 16, 24, 22], fill=(85, 155, 75, 255))
    draw.rectangle([36, 40, 52, 46], fill=(55, 105, 50, 255))
    # Tile (1,0): Camino empedrado
    draw.rectangle([64, 0, 127, 63], fill=(138, 130, 118, 255), outline=(105, 98, 88, 255))
    draw.ellipse([72, 10, 96, 26], fill=(165, 158, 145, 255))
    draw.ellipse([98, 30, 120, 50], fill=(115, 108, 98, 255))
    # Tile (0,1): Obstáculo / Muro con transparencia exterior
    draw.rectangle([4, 68, 60, 124], fill=(90, 85, 80, 255), outline=(130, 125, 120, 255), width=2)
    # Tile (1,1): Agua transparente
    draw.rectangle([64, 64, 127, 127], fill=(50, 120, 180, 200), outline=(90, 160, 220, 255))
    draw.line([(70, 80), (100, 80)], fill=(120, 190, 240, 220), width=2)
    draw.line([(85, 105), (115, 105)], fill=(120, 190, 240, 220), width=2)

    img.save(path, format="PNG")
    print(f"  [OK] Creado tilesheet (2x2 tiles 64x64): {path} ({path.stat().st_size} bytes)")


def main():
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    sprite_path = ASSETS_DIR / "test_sprite.png"
    sheet_path = ASSETS_DIR / "test_spritesheet.png"
    tile_path = ASSETS_DIR / "test_tilesheet.png"

    print("=== Generando activos de prueba para pipeline 2D ===")
    create_test_sprite(sprite_path)
    create_test_spritesheet(sheet_path)
    create_test_tilesheet(tile_path)

    # Validar que Godot importa los activos en modo headless
    print("\n=== Validando importacion en Godot (headless) ===")
    cmd = [str(GODOT_CON), "--headless", "--quit", "--path", str(GODOT_DIR)]
    res = subprocess.run(cmd, capture_output=True, text=True)
    print(f"Exit code Godot: {res.returncode}")
    if res.stdout:
        print("Stdout:\n" + res.stdout)
    if res.stderr:
        print("Stderr:\n" + res.stderr)

    if res.returncode == 0:
        print("  [OK] Godot importo los activos 2D sin errores.")
    else:
        print("  [!!] Error al importar en Godot.")
        sys.exit(1)


if __name__ == "__main__":
    main()
