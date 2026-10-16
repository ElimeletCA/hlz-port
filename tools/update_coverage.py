"""
tools/update_coverage.py — Actualiza docs/coverage.csv con matriz enriquecida por región y estado.
Refleja contenido original, región, tipo de recurso, referencias, estado de lógica, arte, validación y aprobación.
"""

import csv
import json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
MAPS_DIR = REPO_ROOT / "out" / "maps"
COVERAGE_CSV = REPO_ROOT / "docs" / "coverage.csv"

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
        "verificado_emulador", "pendiente", "aprobado_fase0", "APPROVED_GATE_A",
        "input/Heroes Lore Zero 360x640 Spanish.jar", "v4.4.45 360x640 Spanish. Clase principal: rpg.RPGHeroEx"
    ],
    [
        "sistema", "SISTEMA_SAVE", "Sistema de guardado", "Global", "sistema_motor", "si",
        "implementado_parcial", "no_aplica", "verificado_motor", "PENDING_GATE_D",
        "docs/reference/permitir-guardado-3-partidas.jpg", "3 ranuras independientes en user://saves/ (SaveManager)"
    ],
    [
        "sistema", "SISTEMA_BAUL", "Almacenamiento público compartido", "Global", "sistema_motor", "si",
        "especificado", "no_aplica", "pendiente", "PENDING_GATE_D",
        "docs/reference/permitir-transferir-cosas-entre-partidas-guardadas.jpg", "Baúl común transferible entre partidas guardadas"
    ],
    [
        "personaje", "HERO_LUCIAN", "Lucian", "Global", "personaje_jugable", "si",
        "implementado_controlador", "validado_motor", "aprobado_suite", "APPROVED_GATE_B",
        "docs/reference/clase-asesino.jpg", "Protagonista canonico. Asesino hero/h1 auditado al 100% (134 sprites)"
    ],
    [
        "clase", "CLASE_ASESINO", "Asesino", "Global", "clase_jugable", "si",
        "implementado_controlador", "validado_motor", "aprobado_suite", "APPROVED_GATE_B",
        "docs/reference/clase-asesino.jpg", "Doble daga, agilidad, armadura ligera l00. Habilidad Danza Sombria"
    ],
    [
        "clase", "CLASE_GUERRERO", "Guerrero", "Global", "clase_jugable", "si",
        "especificado", "referencia_preparada", "verificado_fase3", "PENDING_GATE_B",
        "docs/reference/clase-guerrero.jpg", "Mandoble a dos manos, armadura pesada. Habilidad Golpe Brutal"
    ],
    [
        "clase", "CLASE_CABALLERO", "Caballero", "Global", "clase_jugable", "si",
        "especificado", "referencia_preparada", "verificado_fase3", "PENDING_GATE_B",
        "docs/reference/clase-caballero.jpg", "Espada y escudo, alta defensa. Habilidad Barcaza de Escudo"
    ],
    [
        "clase", "CLASE_PISTOLERO", "Pistolero", "Global", "clase_jugable", "si",
        "especificado", "referencia_preparada", "verificado_fase3", "PENDING_GATE_B",
        "docs/reference/clase-pistolero.jpg", "Doble pistola, combate a distancia. Habilidad Disparo Cercano"
    ],
    [
        "clase", "CLASE_ELEMENTAL", "Elemental", "Global", "clase_jugable", "si",
        "especificado", "referencia_preparada", "pendiente", "BLOCKED_GATE_D",
        "docs/reference/clase-elemental-se-desbloquea-luego-darle-fin-primera-vez.jpg", "Clase New Game+ desbloqueable tras fin del juego (Flag 250)"
    ],
    [
        "clase", "CLASE_GUNBLADER", "Gunblader", "Global", "clase_jugable", "si",
        "especificado", "referencia_preparada", "pendiente", "BLOCKED_GATE_D",
        "docs/reference/clase-gunblader-se-desbloquea-luego-darle-fin-primera-vez.jpg", "Clase New Game+ desbloqueable tras fin del juego (Flag 251)"
    ],
]

rows = list(base_rows)

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

        # Estado según hito del plan
        if mid == "m_00":
            est_logica = "integrado_fase5"
            est_arte = "validado_motor"
            est_val = "verificado_motor"
            est_aprob = "PENDING_GATE_D"
        elif "Silverleaf" in region:
            est_logica = "extraido_json"
            est_arte = "renderizado_png"
            est_val = "pendiente_fase5"
            est_aprob = "PENDING_GATE_D"
        else:
            est_logica = "extraido_json"
            est_arte = "renderizado_png"
            est_val = "pendiente_fase6"
            est_aprob = "BLOCKED_GATE_D"

        rows.append([
            cat, mid, name, region, tipo, "si",
            est_logica, est_arte, est_val, est_aprob,
            raw_name, notes
        ])

HEADER = [
    "categoria", "id", "nombre_original", "region", "tipo_recurso", "referencia_disponible",
    "estado_logica", "estado_arte", "estado_validacion", "estado_aprobacion",
    "fuente_referencia", "notas"
]

with open(COVERAGE_CSV, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(HEADER)
    writer.writerows(rows)

print(f"[OK] {COVERAGE_CSV} actualizado con {len(rows)} filas y estructura regional.")
