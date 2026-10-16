"""
tools/update_coverage.py — Actualiza docs/coverage.csv preservando filas manuales y estados existentes.
Evita el borrado silencioso de filas gestionadas manualmente y asegura la trazabilidad documental.
"""

import csv
import json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
MAPS_DIR = REPO_ROOT / "out" / "maps"
COVERAGE_CSV = REPO_ROOT / "docs" / "coverage.csv"

HEADER = [
    "categoria", "id", "nombre_original", "region", "tipo_recurso", "referencia_disponible",
    "estado_logica", "estado_arte", "estado_validacion", "estado_aprobacion",
    "fuente_referencia", "notas"
]

def determine_region(mid: str, name: str) -> str:
    n_lower = name.lower()
    if any(k in n_lower for k in ["silverleaf", "orfanato"]):
        return "Region 1 - Aldea Silverleaf y Alrededores"
    elif any(k in n_lower for k in ["melon", "humming", "puerto"]):
        return "Region 2 - Ciudad Humming y Aldea Melon"
    elif any(k in n_lower for k in ["ciruelo", "chelen", "aislado", "caza"]):
        return "Region 3 - Ciudad Ciruelo y Territorios Exteriores"
    elif any(k in n_lower for k in ["fortaleza", "templo", "cueva subterranea", "arena - subsuelo"]):
        return "Region 4 - Fortaleza del Sur, Templo y Subsuelo"
    elif any(k in n_lower for k in ["jefe", "anthony", "alicia", "aquila", "chimera", "timoros", "perro", "dios", "carnivora", "fin", "sufrimiento"]):
        return "Region 5 - Arenas de Jefes Finales y Clímax"
    else:
        return "Region 1 - Aldea Silverleaf y Alrededores" if mid.startswith("m_0") else "Region 4 - Fortaleza del Sur, Templo y Subsuelo"

base_rows = [
    [
        "info", "MIDLET", "Heroes Lore Zero", "Global", "midlet_j2me", "si",
        "verificado_contra_original", "referencia_preparada", "verificado_contra_original", "APPROVED_GATE_A",
        "input/Heroes Lore Zero 360x640 Spanish.jar", "v4.4.45 360x640 Spanish. Clase principal: rpg.RPGHeroEx"
    ],
    [
        "sistema", "SISTEMA_SAVE", "Sistema de guardado", "Global", "sistema_motor", "si",
        "implementado", "no_aplica", "validado_tecnicamente", "PENDING_GATE_D",
        "docs/reference/permitir-guardado-3-partidas.jpg", "3 ranuras independientes en user://saves/ (SaveManager)"
    ],
    [
        "sistema", "SISTEMA_BAUL", "Almacenamiento público compartido", "Global", "sistema_motor", "si",
        "interpretado", "no_aplica", "pendiente", "PENDING_GATE_D",
        "docs/reference/permitir-transferir-cosas-entre-partidas-guardadas.jpg", "Baúl común transferible entre partidas guardadas"
    ],
    [
        "personaje", "HERO_LUCIAN", "Lucian", "Global", "personaje_jugable", "si",
        "implementado", "validado_tecnicamente", "verificado_contra_original", "APPROVED_GATE_B",
        "docs/reference/clase-asesino.jpg", "Protagonista canónico. Asesino hero/h1 auditado al 100% (134 sprites)"
    ],
    [
        "clase", "CLASE_ASESINO", "Asesino", "Global", "clase_jugable", "si",
        "implementado", "validado_tecnicamente", "verificado_contra_original", "APPROVED_GATE_B",
        "docs/reference/clase-asesino.jpg", "Doble daga, agilidad, armadura ligera l00. Habilidad Danza Sombría"
    ],
    [
        "clase", "CLASE_GUERRERO", "Guerrero", "Global", "clase_jugable", "si",
        "interpretado", "referencia_preparada", "validado_tecnicamente", "PENDING_GATE_B",
        "docs/reference/clase-guerrero.jpg", "Mandoble a dos manos, armadura pesada. Habilidad Golpe Brutal"
    ],
    [
        "clase", "CLASE_CABALLERO", "Caballero", "Global", "clase_jugable", "si",
        "interpretado", "referencia_preparada", "validado_tecnicamente", "PENDING_GATE_B",
        "docs/reference/clase-caballero.jpg", "Espada y escudo, alta defensa. Habilidad Barcaza de Escudo"
    ],
    [
        "clase", "CLASE_PISTOLERO", "Pistolero", "Global", "clase_jugable", "si",
        "interpretado", "referencia_preparada", "validado_tecnicamente", "PENDING_GATE_B",
        "docs/reference/clase-pistolero.jpg", "Doble pistola, combate a distancia. Habilidad Disparo Cercano"
    ],
    [
        "clase", "CLASE_ELEMENTAL", "Elemental", "Global", "clase_jugable", "si",
        "interpretado", "referencia_preparada", "pendiente", "BLOQUEADO_POR_GATE_D",
        "docs/reference/clase-elemental-se-desbloquea-luego-darle-fin-primera-vez.jpg", "Clase New Game+ desbloqueable tras fin del juego (Flag 250)"
    ],
    [
        "clase", "CLASE_GUNBLADER", "Gunblader", "Global", "clase_jugable", "si",
        "interpretado", "referencia_preparada", "pendiente", "BLOQUEADO_POR_GATE_D",
        "docs/reference/clase-gunblader-se-desbloquea-luego-darle-fin-primera-vez.jpg", "Clase New Game+ desbloqueable tras fin del juego (Flag 251)"
    ],
]

def load_existing_coverage(csv_path: Path) -> dict:
    """Carga filas existentes indizadas por id para preservar cambios manuales."""
    if not csv_path.exists():
        return {}
    existing = {}
    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            row_id = row.get("id")
            if row_id:
                existing[row_id] = row
    return existing

def main():
    existing_rows = load_existing_coverage(COVERAGE_CSV)
    preserved_manual_count = 0
    updated_map_count = 0
    added_new_count = 0
    
    # Conjunto para rastrear qué IDs han sido procesados
    processed_ids = set()
    final_rows = []

    # 1. Procesar base_rows: si ya existe en CSV, conservar estado manual
    for b in base_rows:
        b_dict = dict(zip(HEADER, b))
        b_id = b_dict["id"]
        processed_ids.add(b_id)
        if b_id in existing_rows:
            # Conservar estados y notas manuales existentes
            curr = existing_rows[b_id]
            final_rows.append(curr)
            preserved_manual_count += 1
        else:
            final_rows.append(b_dict)
            added_new_count += 1

    # 2. Procesar mapas desde out/maps/
    if MAPS_DIR.exists():
        map_files = sorted(MAPS_DIR.glob("*.json"))
        for mf in map_files:
            with open(mf, "r", encoding="utf-8") as f:
                d = json.load(f)
            raw_name = d.get("name", mf.stem)
            mid = raw_name.replace("m/m/", "m_").replace("m/m2/", "m2_").replace(".m", "")
            loc = d.get("location_name", "")
            sub = d.get("sub_location", "")
            name = f"{loc} - {sub}" if sub else loc
            w = d.get("width", 0)
            h = d.get("height", 0)
            ts0 = d.get("tileset_0", 0)
            ts1 = d.get("tileset_1", 255)
            cat = "jefe" if ("Jefe" in loc or "jefe" in sub.lower()) else "mapa"
            tipo = "arena_jefe" if cat == "jefe" else "mapa_entorno"
            region = determine_region(mid, name)
            objs = len(d.get("objects", []))
            spawns = len(d.get("spawns", []))
            notes = f"Tiles: {w}x{h} (16x16 px). Tilesets: t{ts0:02d}, t{ts1:02d}. Objs: {objs}, Spawns: {spawns}"

            processed_ids.add(mid)

            if mid in existing_rows:
                # Actualizar metadatos técnicos (dimensiones, tilesets) conservando estados de auditoría manual
                curr = existing_rows[mid]
                curr["region"] = region
                curr["tipo_recurso"] = tipo
                curr["fuente_referencia"] = raw_name
                # Solo actualizar notas técnicas si las notas no fueron personalizadas manualmente
                if "Tiles:" in curr.get("notas", ""):
                    curr["notas"] = notes
                final_rows.append(curr)
                updated_map_count += 1
            else:
                # Nuevo mapa no presente en el CSV
                if mid == "m_00":
                    est_logica = "en_integracion_fase5"
                    est_arte = "validado_tecnicamente"
                    est_val = "verificado_contra_original"
                    est_aprob = "PENDING_GATE_D"
                elif "Silverleaf" in region:
                    est_logica = "interpretado"
                    est_arte = "extraido_png"
                    est_val = "pendiente_fase5"
                    est_aprob = "PENDING_GATE_D"
                else:
                    est_logica = "interpretado"
                    est_arte = "extraido_png"
                    est_val = "pendiente_fase6"
                    est_aprob = "BLOQUEADO_POR_GATE_D"

                new_row = {
                    "categoria": cat,
                    "id": mid,
                    "nombre_original": name,
                    "region": region,
                    "tipo_recurso": tipo,
                    "referencia_disponible": "si",
                    "estado_logica": est_logica,
                    "estado_arte": est_arte,
                    "estado_validacion": est_val,
                    "estado_aprobacion": est_aprob,
                    "fuente_referencia": raw_name,
                    "notas": notes
                }
                final_rows.append(new_row)
                added_new_count += 1

    # 3. Preservar CUALQUIER otra fila manual que estuviera en el CSV y no coincida con mapas o base_rows
    for row_id, row_data in existing_rows.items():
        if row_id not in processed_ids:
            final_rows.append(row_data)
            preserved_manual_count += 1
            print(f"[PRESERVADO] Fila gestionada manualmente conservada: {row_id} ({row_data.get('categoria')})")

    # 4. Escribir CSV final respetando el encabezado canónico
    with open(COVERAGE_CSV, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=HEADER)
        writer.writeheader()
        writer.writerows(final_rows)

    print(f"[OK] {COVERAGE_CSV} actualizado de forma segura:")
    print(f"  - Total filas escritas: {len(final_rows)}")
    print(f"  - Filas manuales/existentes preservadas intactas: {preserved_manual_count}")
    print(f"  - Mapas actualizados sin sobreescribir auditoría: {updated_map_count}")
    print(f"  - Nuevas filas añadidas: {added_new_count}")

if __name__ == "__main__":
    main()
