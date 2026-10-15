"""
tools/inventory_jar.py — Inventario exhaustivo del contenido del .jar (T2.1).
Calcula tamaño, tamaño comprimido, extensión y SHA-256 por cada archivo dentro del JAR.
Genera docs/inventory.csv y muestra resumen por extensiones y directorios.
"""

import csv
import hashlib
from pathlib import Path
import zipfile

REPO_ROOT = Path(__file__).resolve().parent.parent
JAR_PATH = REPO_ROOT / "input" / "Heroes Lore Zero 360x640 Spanish.jar"
CSV_PATH = REPO_ROOT / "docs" / "inventory.csv"


def inventory_jar():
    if not JAR_PATH.exists():
        raise FileNotFoundError(f"No se encuentra el JAR en: {JAR_PATH}")

    print(f"Abriendo JAR: {JAR_PATH} ({JAR_PATH.stat().st_size:,} bytes)...")

    records = []
    ext_counter = {}
    dir_counter = {}

    with zipfile.ZipFile(JAR_PATH, "r") as z:
        entries = [info for info in z.infolist() if not info.is_dir()]
        print(f"Total de archivos detectados: {len(entries)}")

        for info in entries:
            name = info.filename
            data = z.read(name)
            size_uncompressed = len(data)
            size_compressed = info.compress_size
            sha256 = hashlib.sha256(data).hexdigest()

            # Extensión
            p = Path(name)
            ext = p.suffix.lower() if p.suffix else "(sin extension)"
            ext_counter[ext] = ext_counter.get(ext, 0) + 1

            # Directorio raíz dentro del JAR
            top_dir = name.split("/")[0] if "/" in name else "(raiz)"
            dir_counter[top_dir] = dir_counter.get(top_dir, 0) + 1

            records.append({
                "ruta": name,
                "extension": ext,
                "tamano_bytes": size_uncompressed,
                "tamano_comprimido": size_compressed,
                "crc32": f"{info.CRC:08X}",
                "sha256": sha256
            })

    # Guardar en CSV
    fieldnames = ["ruta", "extension", "tamano_bytes", "tamano_comprimido", "crc32", "sha256"]
    with open(CSV_PATH, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)

    print(f"\n[OK] Inventario guardado en: {CSV_PATH} ({len(records)} entradas)")

    print("\n=== Resumen por extensiones ===")
    for ext, count in sorted(ext_counter.items(), key=lambda x: x[1], reverse=True):
        print(f"  {ext:18s}: {count:5d} archivos")

    print("\n=== Resumen por directorios principales ===")
    for d, count in sorted(dir_counter.items(), key=lambda x: x[1], reverse=True):
        print(f"  {d:18s}: {count:5d} archivos")


if __name__ == "__main__":
    inventory_jar()
