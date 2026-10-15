"""
tools/update_coverage.py — Actualiza docs/coverage.csv con todos los contenidos confirmados (T1.3).
Incorpora mapas, jefes, clases y sistemas confirmados tras la Fase 2.
"""

import csv
import json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
MAPS_DIR = REPO_ROOT / "out" / "maps"
COVERAGE_CSV = REPO_ROOT / "docs" / "coverage.csv"

base_rows = [
    ["info", "MIDLET", "Heroes Lore Zero", "v4.4.45 360x640 Spanish", "verificado_emulador", "pendiente", "input/Heroes Lore Zero 360x640 Spanish.jar", "Clase principal: rpg.RPGHeroEx"],
    ["sistema", "SISTEMA_SAVE", "Sistema de guardado", "3 ranuras de guardado independientes", "confirmado", "no_aplica", "docs/reference/permitir-guardado-3-partidas.jpg", "3 ranuras estandar"],
    ["sistema", "SISTEMA_BAUL", "Almacenamiento publico compartido", "Permite transferir oro equipos y elementos entre ranuras de guardado", "confirmado", "no_aplica", "docs/reference/permitir-transferir-cosas-entre-partidas-guardadas.jpg", "Baul comun entre ranuras"],
    ["personaje", "HERO_LUCIAN", "Lucian", "Protagonista del juego", "confirmado", "referencia_preparada", "docs/reference/clase-guerrero.jpg", "Pelo rojo vestimenta azulada"],
    ["clase", "CLASE_GUERRERO", "Guerrero", "Estilo mandoble / armadura pesada cuerpo a cuerpo", "confirmado", "referencia_preparada", "docs/reference/clase-guerrero.jpg", "Recomendado principiantes"],
    ["clase", "CLASE_ASESINO", "Asesino", "Estilo doble daga / armadura liviana esquiva", "confirmado", "referencia_preparada", "docs/reference/clase-asesino.jpg", "Recomendado expertos"],
    ["clase", "CLASE_CABALLERO", "Caballero", "Estilo espada y escudo / armadura pesada defensa alta", "confirmado", "referencia_preparada", "docs/reference/clase-caballero.jpg", "Recomendado principiantes"],
    ["clase", "CLASE_PISTOLERO", "Pistolero", "Estilo dos pistolas / armadura liviana distancia", "confirmado", "referencia_preparada", "docs/reference/clase-pistolero.jpg", "Recomendado expertos"],
    ["clase", "CLASE_ELEMENTAL", "Elemental", "Clase avanzada secreta (color purpura/violeta) desbloqueada tras completar el juego", "confirmado", "referencia_preparada", "docs/reference/clase-elemental-se-desbloquea-luego-darle-fin-primera-vez.jpg", "Desbloqueable NewGame+"],
    ["clase", "CLASE_GUNBLADER", "Gunblader", "Clase avanzada secreta (color cian/turquesa) hibrido sable-pistola desbloqueada tras fin", "confirmado", "referencia_preparada", "docs/reference/clase-gunblader-se-desbloquea-luego-darle-fin-primera-vez.jpg", "Desbloqueable NewGame+"],
]

rows = list(base_rows)

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
    desc = f"Dimensiones {w}x{h} tiles (16x16 px). Tilesets: t{ts0:02d}, t{ts1:02d}"
    cat = "jefe" if ("Jefe" in loc or "jefe" in sub.lower()) else "mapa"
    objs = len(d.get("objects", []))
    spawns = len(d.get("spawns", []))
    notes = f"Objetos: {objs}, Spawns: {spawns}"
    rows.append([cat, mid, name, desc, "extraido_json", "renderizado_png", raw_name, notes])

with open(COVERAGE_CSV, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["categoria", "id", "nombre_original", "descripcion", "estado_logica", "estado_arte", "fuente_referencia", "notas"])
    writer.writerows(rows)

print(f"[OK] {COVERAGE_CSV} actualizado con {len(rows)} filas.")
