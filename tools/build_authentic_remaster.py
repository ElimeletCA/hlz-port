"""
tools/build_authentic_remaster.py
=================================
Extrae y remasteriza los activos gráficos auténticos del juego original Heroes Lore: Zero (J2ME, 2008)
con reescalado entero 4x (nearest neighbor) para el port de PC en Godot 4.
"""

import os
import io
import struct
import zipfile
from pathlib import Path
from PIL import Image

REPO_ROOT = Path(__file__).resolve().parent.parent
JAR_PATH = REPO_ROOT / "input" / "Heroes Lore Zero 360x640 Spanish.jar"
ART_SAMPLES_DIR = REPO_ROOT / "godot" / "art_samples"

PNG_SIG = b"\x89PNG\r\n\x1a\n"
IEND_CHUNK = b"\x00\x00\x00\x00IEND\xaeB`\x82"


def _u16(b: bytes, off: int) -> int:
    return struct.unpack(">H", b[off:off + 2])[0]


def _u32(b: bytes, off: int) -> int:
    return struct.unpack(">I", b[off:off + 4])[0]


def extract_frame_chunks(buf: bytes, start_off: int, end_off: int):
    chunks = {}
    off = start_off
    while off + 8 <= end_off:
        clen = _u32(buf, off)
        tag = buf[off + 4:off + 8]
        if off + 12 + clen > end_off:
            break
        chunks[tag] = buf[off:off + 12 + clen]
        off += 12 + clen
    return chunks


def load_mpm(z: zipfile.ZipFile, path: str):
    if not path.endswith(".mpm"):
        path += ".mpm"
    raw = z.read(path)
    len_c = _u16(raw, 0)
    block_c = raw[2:2 + len_c]
    num_frames = _u32(block_c, 4)
    off = 2 + len_c
    sub_blocks = []
    while off + 2 <= len(raw):
        blen = _u16(raw, off)
        off += 2
        sub_blocks.append(raw[off:off + blen])
        off += blen

    c_chunks = extract_frame_chunks(block_c, 8 + num_frames * 8, len(block_c))
    offsets = []
    for f in range(num_frames):
        rec_off = 8 + f * 8
        offsets.append((_u16(block_c, rec_off), _u32(block_c, rec_off + 2)))

    frames = []
    for f in range(num_frames):
        sub_idx, chunk_off = offsets[f]
        sub_data = sub_blocks[sub_idx]
        next_off = offsets[f + 1][1] if (f + 1 < num_frames and offsets[f + 1][0] == sub_idx) else len(sub_data)
        f_chunks = extract_frame_chunks(sub_data, chunk_off, next_off)
        ihdr = f_chunks.get(b"IHDR")
        idat = f_chunks.get(b"IDAT")
        plte = f_chunks.get(b"PLTE") or c_chunks.get(b"PLTE")
        trns = f_chunks.get(b"tRNS") or c_chunks.get(b"tRNS")
        png_bytes = PNG_SIG + ihdr + (plte or b"") + (trns or b"") + idat + IEND_CHUNK
        frames.append(Image.open(io.BytesIO(png_bytes)).convert("RGBA"))
    return frames


def render_map_authentic(z: zipfile.ZipFile, map_path: str) -> Image.Image:
    data = z.read(map_path)
    flags, ts0, ts1 = data[0], data[1], data[2]
    off = 3
    for _ in range(2):
        l = data[off]
        off += 1
        if l > 0:
            off += l
    obj_def_count = data[off]
    off += 1
    obj_defs = list(data[off:off + obj_def_count])
    off += obj_def_count
    w, h = data[off], data[off + 1]
    off += 2
    ground = data[off:off + w * h]
    off += w * h
    overlay = data[off:off + w * h]
    off += w * h
    obj_count = data[off]
    off += 1
    placed = []
    for _ in range(obj_count):
        oid = data[off]
        ox = struct.unpack("<h", data[off + 1:off + 3])[0]
        oy = struct.unpack("<h", data[off + 3:off + 5])[0]
        placed.append((oid, ox, oy))
        off += 5
    decor_count = data[off]
    off += 1
    decors = []
    for _ in range(decor_count):
        oid = data[off]
        ox = struct.unpack("<h", data[off + 1:off + 3])[0]
        oy = struct.unpack("<h", data[off + 3:off + 5])[0]
        decors.append((oid, ox, oy))
        off += 5

    ts0_frames = load_mpm(z, f"m/t{ts0:02d}.mpm")
    ts1_frames = load_mpm(z, f"m/t{ts1:02d}.mpm") if ts1 != 255 else []
    all_tiles = ts0_frames + ts1_frames
    split = len(ts0_frames)

    d_counts = [33, 55, 49, 13, 20]
    ob_cache = {}
    resolved_objs = []
    for oid in obj_defs:
        acc = 0
        ob_idx = 0
        local_idx = oid
        for i, cnt in enumerate(d_counts):
            acc += cnt
            if oid < acc:
                ob_idx = i
                local_idx = oid - (acc - cnt)
                break
        if ob_idx not in ob_cache:
            ob_cache[ob_idx] = load_mpm(z, f"m/ob{ob_idx}.mpm")
        resolved_objs.append(ob_cache[ob_idx][local_idx])

    obj_map = {oid: img for oid, img in zip(obj_defs, resolved_objs)}

    map_img = Image.new("RGBA", (w * 16, h * 16), (20, 24, 28, 255))
    for y in range(h):
        for x in range(w):
            val = ground[y * w + x]
            v_offset = split if (val & 128) != 0 else 0
            v_idx = v_offset + (val & 127) - 1
            if 0 <= v_idx < len(all_tiles):
                tile = all_tiles[v_idx]
                map_img.paste(tile, (x * 16, y * 16), tile)

    placed_sorted = sorted(placed, key=lambda o: o[2])
    for oid, ox, oy in placed_sorted:
        if oid in obj_map:
            obj_img = obj_map[oid]
            x = ox - obj_img.width // 2
            y = oy - obj_img.height
            map_img.paste(obj_img, (x, y), obj_img)

    decors_sorted = sorted(decors, key=lambda o: o[2])
    for oid, ox, oy in decors_sorted:
        if oid in obj_map:
            obj_img = obj_map[oid]
            x = ox - obj_img.width // 2
            y = oy - obj_img.height
            map_img.paste(obj_img, (x, y), obj_img)

    return map_img


def build_hero_renderer(z: zipfile.ZipFile, class_id: int = 1, w_main: str = None, w_off: str = None):
    """
    Construye el renderizador de capas compuestas de Lucian segun la especificacion exacta de rpg/c.java.
    class_id:
      0 = Guerrero (Espadon hero/w/100, armadura 00, 7 capas)
      1 = Asesino (Doble daga hero/w/400 x2, armadura ligera l00, 8 capas)
      2 = Caballero (Espada 1 mano hero/w/200, escudo hero/w/700, 8 capas)
    """
    if w_main is None:
        if class_id == 0:
            w_main = "hero/w/100"
            w_off = None
        elif class_id == 1:
            w_main = "hero/w/400"
            w_off = "hero/w/400"
        elif class_id == 2:
            w_main = "hero/w/200"
            w_off = "hero/w/700"

    h_path = f"hero/h{class_id}"
    h_data = z.read(h_path)
    num_layers = h_data[0]
    var3 = num_layers + 1
    for i in range(num_layers):
        var5 = h_data[var3]; var3 += 1
        var2 = h_data[var3]; var3 += 1
        var3 += var2 + var5
    num_anims = h_data[var3]; var3 += 1
    anim_offsets = []
    anim_frame_counts = []
    base_off = var3
    for i in range(num_anims):
        anim_offsets.append(var3 - base_off)
        fc = h_data[var3]; var3 += 1
        anim_frame_counts.append(fc)
        for f in range(fc):
            for d in range(4):
                np = h_data[var3]; var3 += 1
                var3 += np * 4
    table_b = h_data[base_off:var3]

    # Resolucion de capas segun rpg/c.java:
    # dq.b = class_id. dq.a() = (class_id % 2 == 0)
    is_even = (class_id % 2 == 0)
    arm_prefix = "" if is_even else "l"
    layer_paths = [
        "hero/0/00",
        f"hero/1/{arm_prefix}00",
        f"hero/2/{arm_prefix}00",
        f"hero/3/{arm_prefix}00",
        f"hero/4/{class_id}",
        "hero/eh",
        w_main
    ]
    if num_layers >= 8:
        layer_paths.append(w_off)

    layers_normal = []
    for lp in layer_paths[:num_layers]:
        if lp:
            layers_normal.append(load_mpm(z, lp))
        else:
            layers_normal.append([])

    layers_flipped = [[img.transpose(Image.FLIP_LEFT_RIGHT) for img in l] for l in layers_normal]
    all_layers = layers_normal + layers_flipped

    def render_frame(anim_id: int, dir_id: int, frame_id: int,
                     canvas_w: int = 64, canvas_h: int = 80,
                     anchor_x: int = 32, anchor_y: int = 60) -> Image.Image:
        # Engine direction indices:
        # 1 = North (Back)
        # 2 = South (Front)
        # 3 = West (Left)
        # 4 = East (Right)
        var6 = anim_offsets[anim_id] + 1
        max_f = anim_frame_counts[anim_id]
        if frame_id >= max_f or frame_id < 0:
            frame_id = 0
        for _ in range(frame_id):
            for _ in range(4):
                np = table_b[var6]; var6 += 1 + np * 4
        for _ in range(dir_id - 1):
            np = table_b[var6]; var6 += 1 + np * 4
        np = table_b[var6]; var6 += 1

        canvas = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))

        for _ in range(np):
            b0 = table_b[var6]
            b1 = table_b[var6 + 1]
            dx = struct.unpack("b", bytes([table_b[var6 + 2]]))[0]
            dy = struct.unpack("b", bytes([table_b[var6 + 3]]))[0]
            var6 += 4
            layer_idx = (b0 & 127) + (0 if (b0 >> 7 == 0) else num_layers)
            slice_idx = b1
            if layer_idx < len(all_layers) and slice_idx < len(all_layers[layer_idx]):
                slice_img = all_layers[layer_idx][slice_idx]
                canvas.paste(slice_img, (anchor_x + dx, anchor_y + dy), slice_img)
        return canvas

    return render_frame


def build_wolf_renderer(z: zipfile.ZipFile):
    anim_path = "en/cif/a02"
    layers_paths = ["en/04", "en/31", "en/40"]
    layers_normal = [load_mpm(z, p) for p in layers_paths]
    layers_flipped = [[img.transpose(Image.FLIP_LEFT_RIGHT) for img in l] for l in layers_normal]
    all_layers = layers_normal + layers_flipped

    cif_data = z.read(anim_path)
    num_layers = cif_data[0]
    var3 = num_layers + 1
    for i in range(num_layers):
        var5 = cif_data[var3]; var3 += 1
        var2 = cif_data[var3]; var3 += 1
        var3 += var2 + var5
    num_anims = cif_data[var3]; var3 += 1
    anim_offsets = []
    anim_frame_counts = []
    base_off = var3
    for i in range(num_anims):
        anim_offsets.append(var3 - base_off)
        fc = cif_data[var3]; var3 += 1
        anim_frame_counts.append(fc)
        for f in range(fc):
            for d in range(4):
                np = cif_data[var3]; var3 += 1
                var3 += np * 4
    table_b = cif_data[base_off:var3]

    def render_frame(anim_id: int, dir_id: int, frame_id: int, size: int = 48) -> Image.Image:
        var6 = anim_offsets[anim_id] + 1
        max_f = anim_frame_counts[anim_id]
        if frame_id >= max_f or frame_id < 0:
            frame_id = 0
        for _ in range(frame_id):
            for _ in range(4):
                np = table_b[var6]; var6 += 1 + np * 4
        for _ in range(dir_id - 1):
            np = table_b[var6]; var6 += 1 + np * 4
        np = table_b[var6]; var6 += 1

        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        center_x = size // 2
        center_y = size - 5
        for _ in range(np):
            b0 = table_b[var6]
            b1 = table_b[var6 + 1]
            dx = struct.unpack("b", bytes([table_b[var6 + 2]]))[0]
            dy = struct.unpack("b", bytes([table_b[var6 + 3]]))[0]
            var6 += 4
            layer_idx = (b0 & 127) + (0 if (b0 >> 7 == 0) else num_layers)
            slice_idx = b1
            if layer_idx < len(all_layers) and slice_idx < len(all_layers[layer_idx]):
                slice_img = all_layers[layer_idx][slice_idx]
                canvas.paste(slice_img, (center_x + dx, center_y + dy), slice_img)
        return canvas

    return render_frame


def build_npc_renderer(z: zipfile.ZipFile, npc_id: int = 5):
    ndf = z.read("en/ndf")
    off = 0
    for _ in range(npc_id):
        rlen = struct.unpack(">H", ndf[off:off + 2])[0]
        off += rlen + 2
    rlen = struct.unpack(">H", ndf[off:off + 2])[0]
    rec = ndf[off + 2:off + 2 + rlen]

    h_id = rec[0]
    pal_ids = list(rec[1:5])
    layer_ids = list(rec[5:9])
    cif_path = f"en/cif/h{h_id:02d}"
    cif_data = z.read(cif_path)
    num_layers = cif_data[0]
    var3 = num_layers + 1
    for i in range(num_layers):
        var5 = cif_data[var3]; var3 += 1
        var2 = cif_data[var3]; var3 += 1
        var3 += var2 + var5
    num_anims = cif_data[var3]; var3 += 1
    anim_offsets = []
    anim_frame_counts = []
    base_off = var3
    for i in range(num_anims):
        anim_offsets.append(var3 - base_off)
        fc = cif_data[var3]; var3 += 1
        anim_frame_counts.append(fc)
        for f in range(fc):
            for d in range(4):
                np = cif_data[var3]; var3 += 1
                var3 += np * 4
    table_b = cif_data[base_off:var3]

    layers_normal = []
    for l_idx in range(4):
        p = f"en/{l_idx}/{layer_ids[l_idx]:02d}"
        try:
            layers_normal.append(load_mpm(z, p))
        except Exception:
            layers_normal.append([])
    layers_flipped = [[img.transpose(Image.FLIP_LEFT_RIGHT) for img in l] for l in layers_normal]
    all_layers = layers_normal + layers_flipped

    def render_frame(anim_id: int, dir_id: int, frame_id: int, size: int = 32) -> Image.Image:
        var6 = anim_offsets[anim_id] + 1
        max_f = anim_frame_counts[anim_id]
        if frame_id >= max_f or frame_id < 0:
            frame_id = 0
        for _ in range(frame_id):
            for _ in range(4):
                np = table_b[var6]; var6 += 1 + np * 4
        for _ in range(dir_id - 1):
            np = table_b[var6]; var6 += 1 + np * 4
        np = table_b[var6]; var6 += 1
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        center_x = size // 2
        center_y = size - 3
        for _ in range(np):
            b0 = table_b[var6]
            b1 = table_b[var6 + 1]
            dx = struct.unpack("b", bytes([table_b[var6 + 2]]))[0]
            dy = struct.unpack("b", bytes([table_b[var6 + 3]]))[0]
            var6 += 4
            layer_idx = (b0 & 127) + (0 if (b0 >> 7 == 0) else num_layers)
            slice_idx = b1
            if layer_idx < len(all_layers) and slice_idx < len(all_layers[layer_idx]):
                slice_img = all_layers[layer_idx][slice_idx]
                canvas.paste(slice_img, (center_x + dx, center_y + dy), slice_img)
        return canvas

    return render_frame


def upscale_4x(img: Image.Image) -> Image.Image:
    """Escalado entero 4x exacto con interpolación Nearest Neighbor (pixel-perfect)."""
    return img.resize((img.width * 4, img.height * 4), Image.Resampling.NEAREST)


def main():
    print("=" * 60)
    print("HEROES LORE: ZERO — GENERADOR DE ARTE AUTÉNTICO REMASTERIZADO")
    print("=" * 60)

    z = zipfile.ZipFile(JAR_PATH)
    ART_SAMPLES_DIR.mkdir(parents=True, exist_ok=True)

    # 1. Mapa Aldea Silverleaf (m/m/00.m)
    print("\n[1/5] Renderizando mapa canónico de Aldea Silverleaf...")
    raw_map = render_map_authentic(z, "m/m/00.m")
    map_4x = upscale_4x(raw_map)
    map_dest = ART_SAMPLES_DIR / "map_silverleaf.png"
    map_4x.save(map_dest)
    print(f"  -> Guardado {map_dest} ({map_4x.size[0]}x{map_4x.size[1]} px)")

    # 2. Héroe Lucian (Clase Asesino canónica + Clase Guerrero)
    print("\n[2/5] Renderizando sprites y ciclos completos de animación de Lucian Asesino (Clase 1)...")
    # Direcciones canónicas:
    # dir 1 = North (Back / Up)
    # dir 2 = South (Front / Down)
    # dir 3 = West (Left)
    # dir 4 = East (Right)
    dirs_map = [
        ("down", 2),
        ("up", 1),
        ("side", 4),
        ("left", 3),
        ("right", 4),
    ]

    hero_render = build_hero_renderer(z, class_id=1, w_main="hero/w/400", w_off="hero/w/400")

    # A) Texturas direccionales base (Idle F0)
    idle_south = upscale_4x(hero_render(0, 2, 0))
    idle_north = upscale_4x(hero_render(0, 1, 0))
    idle_side  = upscale_4x(hero_render(0, 4, 0))
    idle_left  = upscale_4x(hero_render(0, 3, 0))

    idle_south.save(ART_SAMPLES_DIR / "hero_lucian_idle.png")
    idle_south.save(ART_SAMPLES_DIR / "hero_lucian_down.png")
    idle_north.save(ART_SAMPLES_DIR / "hero_lucian_up.png")
    idle_side.save(ART_SAMPLES_DIR / "hero_lucian_side.png")
    idle_left.save(ART_SAMPLES_DIR / "hero_lucian_left.png")
    idle_side.save(ART_SAMPLES_DIR / "hero_lucian_right.png")
    print("  -> Guardadas texturas direccionales base de Lucian (Idle F0)")

    # B) Animación de Reposo / Idle con respiración (Anim 0: 8 frames)
    for d_name, d_id in dirs_map:
        for f in range(8):
            img_idle_f = upscale_4x(hero_render(0, d_id, f))
            img_idle_f.save(ART_SAMPLES_DIR / f"hero_lucian_idle_{d_name}_{f}.png")

    # C) Ciclos de marcha canónicos con armas preparadas (Anim 2: 4 frames expandidos a 8 frames)
    for d_name, d_id in dirs_map:
        for i in range(8):
            f_idx = i % 4
            walk_frame = upscale_4x(hero_render(2, d_id, f_idx))
            walk_frame.save(ART_SAMPLES_DIR / f"hero_lucian_walk_{d_name}_{i}.png")
    print("  -> Guardados 40 fotogramas de caminata con armas (8 por cada dirección: down, up, side, left, right)")

    # D) Animación de Ataque Básico Combo 1 con tajos VFX (Anim 6: 5 frames)
    for d_name, d_id in dirs_map:
        for f in range(5):
            atk_frame = upscale_4x(hero_render(6, d_id, f))
            atk_frame.save(ART_SAMPLES_DIR / f"hero_lucian_atk_{d_name}_{f}.png")
    print("  -> Guardados 25 fotogramas de ataque combo 1 con tajos VFX auténticos")

    # E) Animación de Remate Combo 2 (Anim 7: 3 frames)
    for d_name, d_id in dirs_map:
        for f in range(3):
            fin_frame = upscale_4x(hero_render(7, d_id, f))
            fin_frame.save(ART_SAMPLES_DIR / f"hero_lucian_combo_{d_name}_{f}.png")
    print("  -> Guardados 15 fotogramas de remate aéreo combo 2")

    # F) Animación de Muerte / Caída (Anim 4: 9 frames)
    for f in range(9):
        dead_frame = upscale_4x(hero_render(4, 1, f))
        dead_frame.save(ART_SAMPLES_DIR / f"hero_lucian_dead_{f}.png")
    print("  -> Guardados 9 fotogramas de caída/muerte")

    # G) Exportación opcional de Lucian Guerrero (Clase 0 con Espadón hero/w/100)
    war_render = build_hero_renderer(z, class_id=0, w_main="hero/w/100", w_off=None)
    for d_name, d_id in dirs_map:
        upscale_4x(war_render(0, d_id, 0)).save(ART_SAMPLES_DIR / f"hero_lucian_warrior_{d_name}.png")
        for i in range(8):
            upscale_4x(war_render(2, d_id, i % 4)).save(ART_SAMPLES_DIR / f"hero_lucian_warrior_walk_{d_name}_{i}.png")
        for f in range(6):
            upscale_4x(war_render(6, d_id, f)).save(ART_SAMPLES_DIR / f"hero_lucian_warrior_atk_{d_name}_{f}.png")
    print("  -> Guardados conjuntos de recursos para Lucian Guerrero (Espadón)")

    # 3. Enemigo: Lobo del Bosque (en/cif/a02, dir 2 = Front/South)
    print("\n[3/5] Renderizando Lobo del Bosque auténtico...")
    wolf_render = build_wolf_renderer(z)
    wolf_img = upscale_4x(wolf_render(0, 2, 0, size=48)) # size 48 -> 192x192
    wolf_img.save(ART_SAMPLES_DIR / "enemy_forest_wolf.png")
    print(f"  -> Guardado {ART_SAMPLES_DIR / 'enemy_forest_wolf.png'}")

    # 4. NPC Instructor / Entrenador Aldren (dir 2 = Front/South)
    print("\n[4/5] Renderizando NPC Instructor (Aldren) auténtico...")
    npc_render = build_npc_renderer(z, npc_id=5) # Caballero rubio con túnica y armadura
    npc_img = upscale_4x(npc_render(0, 2, 0)) # dir 2 = South (Front)
    npc_img.save(ART_SAMPLES_DIR / "npc_aldren.png")
    print(f"  -> Guardado {ART_SAMPLES_DIR / 'npc_aldren.png'}")

    # 5. Props: Cofre
    print("\n[5/5] Renderizando cofre auténtico...")
    chest_open_raw = Image.open(io.BytesIO(z.read("chest_opened.png"))).convert("RGBA")
    chest_open_4x = upscale_4x(chest_open_raw)
    chest_open_4x.save(ART_SAMPLES_DIR / "prop_chest_open.png")

    ob4_frames = load_mpm(z, "m/ob4")
    chest_closed_raw = ob4_frames[0]
    chest_closed_4x = upscale_4x(chest_closed_raw)
    chest_closed_4x.save(ART_SAMPLES_DIR / "prop_chest_closed.png")
    print("  -> Guardados prop_chest_open.png y prop_chest_closed.png")

    print("\n" + "=" * 60)
    print("REMASTERIZACIÓN DE ACTIVOS COMPLETADA CON ÉXITO")
    print("=" * 60)


if __name__ == "__main__":
    main()
