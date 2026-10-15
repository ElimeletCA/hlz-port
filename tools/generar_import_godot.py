#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys, io
# Forzar salida UTF-8 para evitar errores en terminales Windows cp1252
if sys.stdout.encoding and sys.stdout.encoding.lower() != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')
"""
Genera archivos .import y .ctex para PNGs que aún no han sido importados por Godot.
Esto replica el proceso de importación del editor Godot 4 para imágenes sin mipmaps
comprimidas en modo lossless (WebP).

Uso:
    python tools/generar_import_godot.py

Ejecutar desde la raíz del repositorio (c:/Proyecto HLZ/hlz-port).
"""

import os
import sys
import hashlib
import struct
import uuid
import subprocess
import shutil

# --- Configuración ---
GODOT_PROJECT = os.path.join(os.path.dirname(__file__), '..', 'godot')
ART_SAMPLES_DIR = os.path.join(GODOT_PROJECT, 'art_samples')
IMPORTED_DIR = os.path.join(GODOT_PROJECT, '.godot', 'imported')

# PNGs que necesitan importación (los que no tienen .import todavía)
ASSETS_FALTANTES = [
    'map_silverleaf.png',
    'npc_aldren.png',
    'prop_barrel.png',
    'prop_cottage.png',
    'prop_fence.png',
    'prop_lantern.png',
    'prop_village_house.png',
]


def md5_archivo(ruta: str) -> str:
    """Calcula el MD5 del contenido de un archivo."""
    h = hashlib.md5()
    with open(ruta, 'rb') as f:
        h.update(f.read())
    return h.hexdigest()


def generar_uid_godot() -> str:
    """
    Genera un UID de Godot en formato uid://xxxxxxxxxxxxxxx
    Godot usa un entero de 64 bits codificado en base62.
    """
    chars = '0123456789abcdefghijklmnopqrstuvwxyz' \
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    # Usar UUID4 truncado como fuente de entropía
    val = uuid.uuid4().int & 0x7FFFFFFFFFFFFFFF  # 63 bits positivos
    result = []
    while val > 0:
        result.append(chars[val % len(chars)])
        val //= len(chars)
    # Rellenar a longitud mínima (Godot UIDs suelen tener ~13 caracteres)
    while len(result) < 13:
        result.append('0')
    return 'uid://' + ''.join(reversed(result))


def png_a_webp_lossless(ruta_png: str) -> bytes:
    """
    Convierte un PNG a WebP lossless usando cwebp si está disponible,
    o usando Pillow como alternativa.
    """
    # Intentar con Pillow (más portable)
    try:
        from PIL import Image
        import io
        img = Image.open(ruta_png)
        buf = io.BytesIO()
        img.save(buf, format='WEBP', lossless=True, quality=100)
        return buf.getvalue()
    except ImportError:
        pass

    # Si no hay Pillow, intentar cwebp externo
    cwebp = shutil.which('cwebp')
    if cwebp:
        import tempfile
        with tempfile.NamedTemporaryFile(suffix='.webp', delete=False) as tmp:
            tmp_path = tmp.name
        try:
            subprocess.run([cwebp, '-lossless', ruta_png, '-o', tmp_path],
                           check=True, capture_output=True)
            with open(tmp_path, 'rb') as f:
                return f.read()
        finally:
            os.unlink(tmp_path)

    raise RuntimeError(
        "No se encontró Pillow ni cwebp. Instala Pillow: pip install Pillow"
    )


def obtener_dimensiones_png(ruta_png: str) -> tuple[int, int]:
    """Extrae width y height del header PNG sin cargar la imagen completa."""
    with open(ruta_png, 'rb') as f:
        f.seek(16)  # Saltar firma PNG (8) + longitud chunk IHDR (4) + tipo (4)
        w = struct.unpack('>I', f.read(4))[0]
        h = struct.unpack('>I', f.read(4))[0]
    return w, h


def construir_ctex(w: int, h: int, webp_data: bytes) -> bytes:
    """
    Construye el archivo .ctex de Godot 4.

    Formato del header (48 bytes):
      - 4 bytes: magic "GST2" (0x47 0x53 0x54 0x32)
      - 4 bytes: version (1, little-endian)
      - 4 bytes: width (little-endian)
      - 4 bytes: height (little-endian)
      - 4 bytes: flags (0x0D000000 en el original -- data_format + flags)
      - 4 bytes: 0xFFFFFFFF (pixel_format = IMAGE_FORMAT_RGBA8)
      - 4 bytes: 0x00000000 (mipmaps = 0)
      - 4 bytes: 0x00000000 (reserved)
      - 4 bytes: 0x00000000 (reserved)
      - 4 bytes: image_data_size_offset (= 2 layers) / layer_count
      - 4 bytes: width | (height << 16) packed otra vez (dimensiones del mip)
      - 4 bytes: 0x00000000

    Seguido de bloque de datos:
      - 4 bytes: tipo de datos (5 = DATA_FORMAT_PNG / WebP en Godot 4)
      - 4 bytes: tamaño del bloque webp
      - N bytes: datos WebP
    """
    # Header exacto analizado de archivos reales de Godot 4.7
    # Offset 0-3:  magic
    magic = b'GST2'
    # Offset 4-7:  version = 1
    version = struct.pack('<I', 1)
    # Offset 8-11: width
    width_b = struct.pack('<I', w)
    # Offset 12-15: height
    height_b = struct.pack('<I', h)
    # Offset 16-19: 0x0D000000 (flags: HAS_MIPMAPS=0, FORMAT=DATA_FORMAT_IMAGE)
    flags = struct.pack('<I', 0x0D000000)
    # Offset 20-23: 0xFFFFFFFF (IMAGE_FORMAT_RGBA8 = 4, pero Godot usa -1 aquí para "usar data")
    pixel_fmt = struct.pack('<I', 0xFFFFFFFF)
    # Offset 24-27: mipmap_count = 0
    mipmaps = struct.pack('<I', 0)
    # Offset 28-31: reserved
    res1 = struct.pack('<I', 0)
    # Offset 32-35: reserved
    res2 = struct.pack('<I', 0)
    # Offset 36-39: layer_count = 2 (lo que vimos: 0x02000000)
    layer_count = struct.pack('<I', 2)
    # Offset 40-43: dimensiones empaquetadas (width | height<<16)
    # Ojo: en el .ctex real esto era w=0x60=96, h=0x80=128 → packed como 0x00800060
    dim_packed = struct.pack('<I', w | (h << 16))
    # Offset 44-47: 0x00000000
    res3 = struct.pack('<I', 0)

    header = magic + version + width_b + height_b + flags + pixel_fmt + \
             mipmaps + res1 + res2 + layer_count + dim_packed + res3

    # Bloque de datos WebP
    # tipo 5 = Godot's DATA_FORMAT_WEBP
    data_type = struct.pack('<I', 5)
    data_size = struct.pack('<I', len(webp_data))
    data_block = data_type + data_size + webp_data

    return header + data_block


def construir_md5_ctex(ruta_png: str, ruta_ctex: str) -> str:
    """
    Genera el contenido del archivo .md5 que acompaña al .ctex.
    Formato: "{md5_source} {md5_dest}\\n"
    """
    md5_src = md5_archivo(ruta_png)
    md5_dst = md5_archivo(ruta_ctex)
    return f"{md5_src} {md5_dst}\n"


def construir_import(nombre_png: str, uid: str, hash_ctex: str) -> str:
    """Genera el contenido del archivo .import para un PNG."""
    res_base = f"res://art_samples/{nombre_png}"
    ctex_path = f"res://.godot/imported/{nombre_png}-{hash_ctex}.ctex"

    return f"""[remap]

importer="texture"
type="CompressedTexture2D"
uid="{uid}"
path="{ctex_path}"
metadata={{
"vram_texture": false
}}

[deps]

source_file="{res_base}"
dest_files=["{ctex_path}"]

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
"""


def procesar_asset(nombre_png: str) -> bool:
    """Procesa un PNG: genera .ctex, .md5 y .import."""
    ruta_png = os.path.join(ART_SAMPLES_DIR, nombre_png)

    if not os.path.exists(ruta_png):
        print(f"  [ERROR] No existe: {ruta_png}")
        return False

    ruta_import = ruta_png + '.import'
    if os.path.exists(ruta_import):
        print(f"  [SKIP]  Ya importado: {nombre_png}")
        return True

    print(f"  [PROC]  Procesando: {nombre_png}")

    # 1. Obtener dimensiones
    w, h = obtener_dimensiones_png(ruta_png)
    print(f"          Dimensiones: {w}x{h}")

    # 2. Convertir a WebP lossless
    print(f"          Convirtiendo a WebP...")
    webp_data = png_a_webp_lossless(ruta_png)
    print(f"          WebP size: {len(webp_data)} bytes")

    # 3. Construir .ctex
    ctex_data = construir_ctex(w, h, webp_data)

    # 4. Determinar nombre del .ctex (usa hash MD5 del PNG original)
    hash_png = md5_archivo(ruta_png)
    nombre_ctex = f"{nombre_png}-{hash_png}.ctex"
    ruta_ctex = os.path.join(IMPORTED_DIR, nombre_ctex)

    # 5. Escribir .ctex
    os.makedirs(IMPORTED_DIR, exist_ok=True)
    with open(ruta_ctex, 'wb') as f:
        f.write(ctex_data)
    print(f"          Escrito: {nombre_ctex}")

    # 6. Escribir .md5
    contenido_md5 = construir_md5_ctex(ruta_png, ruta_ctex)
    ruta_md5 = ruta_ctex.replace('.ctex', '.md5')
    with open(ruta_md5, 'w') as f:
        f.write(contenido_md5)

    # 7. Generar UID único
    uid = generar_uid_godot()

    # 8. Escribir .import
    contenido_import = construir_import(nombre_png, uid, hash_png)
    with open(ruta_import, 'w') as f:
        f.write(contenido_import)
    print(f"          UID: {uid}")
    print(f"          .import creado ✓")

    return True


def main():
    print("=" * 60)
    print("  Generador de imports Godot 4 — Proyecto HLZ")
    print("=" * 60)

    # Verificar que Pillow está disponible
    try:
        import PIL
        print(f"  Pillow {PIL.__version__} disponible ✓")
    except ImportError:
        print("  [WARN] Pillow no disponible. Intentando instalar...")
        subprocess.run([sys.executable, '-m', 'pip', 'install', 'Pillow'],
                       check=True)
        print("  Pillow instalado ✓")

    exitosos = 0
    fallidos = 0

    for nombre_png in ASSETS_FALTANTES:
        try:
            if procesar_asset(nombre_png):
                exitosos += 1
            else:
                fallidos += 1
        except Exception as e:
            print(f"  [ERROR] {nombre_png}: {e}")
            fallidos += 1

    print()
    print(f"  Resultado: {exitosos} exitosos, {fallidos} fallidos")
    print()

    if fallidos == 0:
        print("  ✓ Todos los assets importados. Ya puedes ejecutar el juego.")
    else:
        print("  ✗ Algunos assets fallaron. Revisa los errores arriba.")

    return 0 if fallidos == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
