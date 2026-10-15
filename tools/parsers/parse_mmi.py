"""
tools/parsers/parse_mmi.py — Parser de archivos mmi (Map Mission Indicators).
Extrae las coordenadas de destino para 35 etapas de misión en cada mapa.
"""

from typing import Dict, Tuple, Optional, Any


def parse_mmi(data: bytes) -> Dict[int, Optional[Tuple[int, int]]]:
    """
    Parsea los 70 bytes de un archivo mmi según docs/formats/mmi.md.
    Retorna un diccionario {etapa (1..35): (x, y) | None}.
    """
    if len(data) != 70:
        raise ValueError(f"Tamaño inválido para mmi: {len(data)} bytes (se requieren exactamente 70)")

    markers = {}
    for stage in range(1, 36):
        idx = (stage - 1) * 2
        x = data[idx]
        y = data[idx + 1]

        if x == 255 and y == 255:
            markers[stage] = None
        else:
            markers[stage] = (x, y)

    return markers


def parse_mmi_file(path_or_bytes) -> Dict[str, Any]:
    """Parsea desde ruta o bytes."""
    if isinstance(path_or_bytes, (str, bytes)):
        if isinstance(path_or_bytes, str):
            with open(path_or_bytes, "rb") as f:
                raw = f.read()
        else:
            raw = path_or_bytes
    else:
        raw = path_or_bytes.read()

    markers = parse_mmi(raw)
    active = {k: v for k, v in markers.items() if v is not None}
    return {
        "total_stages": 35,
        "active_markers_count": len(active),
        "markers": markers
    }
