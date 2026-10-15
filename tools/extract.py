"""
tools/extract.py — Exportador y extractor integral de recursos de Heroes Lore: Zero (T2.6).
Uso: python tools/extract.py [ruta_jar] [carpeta_salida]
Por defecto: input/Heroes Lore Zero 360x640 Spanish.jar -> out/
"""

import json
import os
import sys
import zipfile
from pathlib import Path

# Añadir el directorio raíz al path para importar tools.parsers
REPO_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO_ROOT))

from tools.parsers.parse_tdf import parse_tdf
from tools.parsers.parse_mmi import parse_mmi
from tools.parsers.parse_mpm import parse_mpm
from tools.parsers.parse_map import parse_map


def extract_all(jar_path: Path, out_dir: Path):
    if not jar_path.exists():
        print(f"[ERROR] No se encuentra el JAR en: {jar_path}")
        sys.exit(1)

    print(f"=== Iniciando Extraccion Integral de Recursos ===")
    print(f"JAR Origen:  {jar_path}")
    print(f"Directorio:  {out_dir}\n")

    out_dir.mkdir(parents=True, exist_ok=True)

    with zipfile.ZipFile(jar_path, "r") as z:
        all_files = z.namelist()

        # ── 1. Textos (.tdf -> out/text/*.json) ──────────────────────────────
        tdf_dir = out_dir / "text"
        tdf_dir.mkdir(parents=True, exist_ok=True)
        tdf_files = [f for f in all_files if f.endswith(".tdf")]
        print(f"[1/6] Extrayendo {len(tdf_files)} archivos de texto (.tdf)...")
        total_strings = 0
        all_texts = {}
        for f in tdf_files:
            entries = parse_tdf(z.read(f))
            total_strings += len(entries)
            safe_name = f.replace("/", "_").replace(".tdf", ".json")
            with open(tdf_dir / safe_name, "w", encoding="utf-8") as jf:
                json.dump({"source": f, "count": len(entries), "strings": entries}, jf, ensure_ascii=False, indent=2)
            all_texts[f] = entries

        # Archivo maestro de textos
        with open(tdf_dir / "_all_text_master.json", "w", encoding="utf-8") as jf:
            json.dump(all_texts, jf, ensure_ascii=False, indent=2)
        print(f"      [OK] {len(tdf_files)} archivos de texto procesados ({total_strings} cadenas extraídas).")

        # ── 2. Marcadores de Misión (mmi/* -> out/mmi/*.json) ───────────────
        mmi_dir = out_dir / "mmi"
        mmi_dir.mkdir(parents=True, exist_ok=True)
        mmi_files = [f for f in all_files if f.startswith("mmi/") and not f.endswith("/")]
        print(f"[2/6] Extrayendo {len(mmi_files)} marcadores de mision (mmi/)...")
        all_mmis = {}
        for f in mmi_files:
            markers = parse_mmi(z.read(f))
            map_id = f.split("/")[1]
            all_mmis[map_id] = {str(stage): pos for stage, pos in markers.items() if pos is not None}
            with open(mmi_dir / f"mmi_{map_id}.json", "w", encoding="utf-8") as jf:
                json.dump({"map_id": map_id, "markers": all_mmis[map_id]}, jf, indent=2)
        with open(mmi_dir / "_all_mmi_master.json", "w", encoding="utf-8") as jf:
            json.dump(all_mmis, jf, indent=2)
        print(f"      [OK] {len(mmi_files)} indicadores de mapa procesados.")

        # ── 3. Mapas (.m -> out/maps/*.json) ─────────────────────────────────
        map_dir = out_dir / "maps"
        map_dir.mkdir(parents=True, exist_ok=True)
        map_files = [f for f in all_files if f.endswith(".m")]
        print(f"[3/6] Extrayendo {len(map_files)} mapas binarios (.m)...")
        for f in map_files:
            map_data = parse_map(z.read(f), f)
            safe_name = f.replace("/", "_").replace(".m", ".json")
            with open(map_dir / safe_name, "w", encoding="utf-8") as jf:
                json.dump(map_data, jf, indent=2)
        print(f"      [OK] {len(map_files)} mapas exportados a JSON con capas, tiles y entidades.")

        # ── 4. Audio (snd/b/* -> MIDI, snd/e/* -> WAV) ───────────────────────
        audio_dir = out_dir / "audio"
        midi_dir = audio_dir / "midi"
        wav_dir = audio_dir / "wav"
        midi_dir.mkdir(parents=True, exist_ok=True)
        wav_dir.mkdir(parents=True, exist_ok=True)

        midi_files = [f for f in all_files if f.startswith("snd/b/") and not f.endswith("/")]
        wav_files = [f for f in all_files if f.startswith("snd/e/") and not f.endswith("/")]
        print(f"[4/6] Extrayendo audio ({len(midi_files)} pistas MIDI, {len(wav_files)} efectos WAV)...")
        for f in midi_files:
            track_num = f.split("/")[-1]
            (midi_dir / f"bgm_{track_num.zfill(2)}.mid").write_bytes(z.read(f))
        for f in wav_files:
            sfx_num = f.split("/")[-1]
            (wav_dir / f"sfx_{sfx_num.zfill(2)}.wav").write_bytes(z.read(f))
        print(f"      [OK] {len(midi_files)} MIDI y {len(wav_files)} WAV exportados tal cual.")

        # ── 5. Texturas UI nativas (.png -> out/ui/*.png) ────────────────────
        ui_dir = out_dir / "ui"
        ui_dir.mkdir(parents=True, exist_ok=True)
        png_files = [f for f in all_files if f.endswith(".png")]
        print(f"[5/6] Extrayendo {len(png_files)} texturas UI PNG nativas...")
        for f in png_files:
            target_path = ui_dir / f
            target_path.parent.mkdir(parents=True, exist_ok=True)
            target_path.write_bytes(z.read(f))
        print(f"      [OK] {len(png_files)} PNGs de UI extraídos.")

        # ── 6. Gráficos y Spritesheets (.mpm -> out/sprites/) ───────────────
        sprites_dir = out_dir / "sprites"
        sprites_dir.mkdir(parents=True, exist_ok=True)
        mpm_files = [f for f in all_files if f.endswith(".mpm")]
        print(f"[6/6] Reconstruyendo {len(mpm_files)} archivos de sprites .mpm a PNG...")
        total_sprites = 0
        for f in mpm_files:
            raw_data = z.read(f)
            num_frames, frames = parse_mpm(raw_data)
            if frames:
                rel_base = f.replace(".mpm", "")
                target_folder = sprites_dir / rel_base
                target_folder.mkdir(parents=True, exist_ok=True)

                for idx, img in enumerate(frames):
                    img_name = f"frame_{idx:03d}.png" if num_frames > 1 else "sprite.png"
                    img.save(target_folder / img_name, format="PNG")
                    total_sprites += 1
        print(f"      [OK] {len(mpm_files)} archivos .mpm procesados -> {total_sprites} imagenes PNG reconstruidas.")

    print("\n" + "=" * 60)
    print("  ¡EXTRACCION COMPLETADA CON EXITO AL 100%!")
    print(f"  • Textos y Dialogos:    {len(tdf_files)} archivos ({total_strings} cadenas)")
    print(f"  • Mapas Binarios:       {len(map_files)} archivos JSON")
    print(f"  • Indicadores Mision:   {len(mmi_files)} archivos JSON")
    print(f"  • Musica MIDI:          {len(midi_files)} pistas")
    print(f"  • Efectos WAV:          {len(wav_files)} sonidos")
    print(f"  • Texturas UI:          {len(png_files)} imagenes")
    print(f"  • Sprites Reconstruidos:{total_sprites} imagenes PNG")
    print("=" * 60)


if __name__ == "__main__":
    jar = Path(sys.argv[1]) if len(sys.argv) > 1 else REPO_ROOT / "input" / "Heroes Lore Zero 360x640 Spanish.jar"
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else REPO_ROOT / "out"
    extract_all(jar, out)
