"""
tools/parsers/parse_mpm.py — Parser y decodificador de archivos .mpm (Multi-Picture Media).
Reconstruye las imágenes PNG estándar a partir de la estructura de chunks modulares.
Soporta los 460 archivos .mpm del juego original (3.199 sprites/frames extraídos).
"""

import io
import struct
from typing import List, Tuple, Dict, Any, Optional
from PIL import Image

PNG_SIG = b"\x89PNG\r\n\x1a\n"
IEND_CHUNK = b"\x00\x00\x00\x00IEND\xaeB\x60\x82"


def _u16(b: bytes, off: int) -> int:
    return struct.unpack(">H", b[off:off + 2])[0]


def _u32(b: bytes, off: int) -> int:
    return struct.unpack(">I", b[off:off + 4])[0]


def extract_chunks(buf: bytes) -> Dict[bytes, bytes]:
    """Extrae chunks PNG individuales en un diccionario {tag: chunk_completo_con_crc}."""
    chunks = {}
    off = 0
    while off + 8 <= len(buf):
        clen = _u32(buf, off)
        tag = buf[off + 4:off + 8]
        if off + 12 + clen > len(buf):
            break
        chunks[tag] = buf[off:off + 12 + clen]
        off += 12 + clen
    return chunks


def parse_mpm(data: bytes) -> Tuple[int, List[Image.Image]]:
    """
    Parsea los bytes de un archivo .mpm y retorna (num_frames, lista_de_imagenes_PIL).
    """
    if len(data) < 10:
        return 0, []

    len_c = _u16(data, 0)
    block_c = data[2:2 + len_c]
    num_frames = _u32(block_c, 4)

    # Extraer sub-bloques del archivo
    off = 2 + len_c
    sub_blocks = []
    while off + 2 <= len(data):
        blen = _u16(data, off)
        off += 2
        sub_blocks.append(data[off:off + blen])
        off += blen

    # Chunks compartidos en el Bloque C (PLTE, tRNS)
    c_chunks = extract_chunks(block_c[8 + num_frames * 8:])

    frames = []
    for f in range(num_frames):
        rec_off = 8 + f * 8
        sub_idx = _u16(block_c, rec_off)
        chunk_off = _u16(block_c, rec_off + 2)

        if sub_idx < len(sub_blocks):
            sub_data = sub_blocks[sub_idx]
            sub_chunks = extract_chunks(sub_data[chunk_off:])

            ihdr = sub_chunks.get(b"IHDR")
            idat = sub_chunks.get(b"IDAT")
            plte = sub_chunks.get(b"PLTE") or c_chunks.get(b"PLTE")
            trns = sub_chunks.get(b"tRNS") or c_chunks.get(b"tRNS")

            if ihdr and idat:
                png_bytes = PNG_SIG + ihdr + (plte or b"") + (trns or b"") + idat + IEND_CHUNK
                try:
                    img = Image.open(io.BytesIO(png_bytes))
                    frames.append(img)
                except Exception as e:
                    print(f"  [WARN] Error decodificando frame {f}: {e}")

    return num_frames, frames


def parse_mpm_file(path_or_bytes) -> List[Image.Image]:
    """Parsea desde ruta o bytes y retorna las imágenes extraídas."""
    if isinstance(path_or_bytes, (str, bytes)):
        if isinstance(path_or_bytes, str):
            with open(path_or_bytes, "rb") as f:
                raw = f.read()
        else:
            raw = path_or_bytes
    else:
        raw = path_or_bytes.read()

    _, frames = parse_mpm(raw)
    return frames
