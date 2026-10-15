"""
tools/parsers/parse_tdf.py — Parser de archivos .tdf (Text Data Files).
Extrae todas las cadenas de texto y diálogos.
"""

import struct
from typing import List, Dict, Any


def parse_tdf(data: bytes) -> List[str]:
    """
    Parsea los bytes de un archivo .tdf según la especificación de docs/formats/tdf.md.
    Retorna una lista de strings.
    """
    if not data:
        return []

    entry_count = data[0]
    entries = []
    offset = 1

    for _ in range(entry_count):
        if offset + 2 > len(data):
            break
        length = struct.unpack(">H", data[offset:offset + 2])[0]
        offset += 2
        text_raw = data[offset:offset + length]
        offset += length

        try:
            text = text_raw.decode("utf-8")
        except UnicodeDecodeError:
            text = text_raw.decode("latin-1", errors="replace")

        entries.append(text)

    return entries


def parse_tdf_file(path_or_bytes) -> Dict[str, Any]:
    """Parsea desde ruta o bytes y retorna diccionario con metadatos y entradas."""
    if isinstance(path_or_bytes, (str, bytes)):
        if isinstance(path_or_bytes, str):
            with open(path_or_bytes, "rb") as f:
                raw = f.read()
        else:
            raw = path_or_bytes
    else:
        raw = path_or_bytes.read()

    entries = parse_tdf(raw)
    return {
        "total_entries": len(entries),
        "entries": entries
    }
