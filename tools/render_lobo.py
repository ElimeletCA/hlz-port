import zipfile, struct, io
from PIL import Image

def _u16(b, off): return struct.unpack('>H', b[off:off+2])[0]
def _u32(b, off): return struct.unpack('>I', b[off:off+4])[0]

def extract_frame_chunks(buf, start_off, end_off):
    chunks = {}
    off = start_off
    while off + 8 <= end_off:
        clen = _u32(buf, off); tag = buf[off+4:off+8]
        if off + 12 + clen > end_off: break
        chunks[tag] = buf[off:off+12+clen]; off += 12 + clen
    return chunks

def load_mpm(z, path):
    if not path.endswith('.mpm'): path += '.mpm'
    raw = z.read(path)
    len_c = _u16(raw, 0); block_c = raw[2:2+len_c]; num_frames = _u32(block_c, 4)
    off = 2 + len_c; sub_blocks = []
    while off + 2 <= len(raw):
        blen = _u16(raw, off); off += 2
        sub_blocks.append(raw[off:off+blen]); off += blen
    c_chunks = extract_frame_chunks(block_c, 8 + num_frames * 8, len(block_c))
    offsets = []
    for f in range(num_frames):
        rec_off = 8 + f * 8
        offsets.append((_u16(block_c, rec_off), _u32(block_c, rec_off + 2)))
    frames = []
    for f in range(num_frames):
        sub_idx, chunk_off = offsets[f]; sub_data = sub_blocks[sub_idx]
        next_off = offsets[f+1][1] if (f + 1 < num_frames and offsets[f+1][0] == sub_idx) else len(sub_data)
        f_chunks = extract_frame_chunks(sub_data, chunk_off, next_off)
        ihdr, idat = f_chunks.get(b'IHDR'), f_chunks.get(b'IDAT')
        plte = f_chunks.get(b'PLTE') or c_chunks.get(b'PLTE')
        trns = f_chunks.get(b'tRNS') or c_chunks.get(b'tRNS')
        png_bytes = b'\x89PNG\r\n\x1a\n' + ihdr + (plte or b'') + (trns or b'') + idat + b'\x00\x00\x00\x00IEND\xaeB`\x82'
        frames.append(Image.open(io.BytesIO(png_bytes)).convert('RGBA'))
    return frames

z = zipfile.ZipFile('input/Heroes Lore Zero 360x640 Spanish.jar')

# Lobo (Record 21): k=1, lid=2, d=[4, 31, 40]
anim_path = 'en/cif/a02'
layers_paths = ['en/04', 'en/31', 'en/40']
layers_normal = [load_mpm(z, p) for p in layers_paths]
layers_flipped = [[img.transpose(Image.FLIP_LEFT_RIGHT) for img in l] for l in layers_normal]
all_layers = layers_normal + layers_flipped

cif_data = z.read(anim_path)
num_layers = cif_data[0]
var3 = num_layers + 1
for i in range(num_layers):
    var5 = cif_data[var3]; var3 += 1; var2 = cif_data[var3]; var3 += 1; var3 += var2 + var5
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
            np = cif_data[var3]; var3 += 1; var3 += np * 4
table_b = cif_data[base_off:var3]

print(f"Lobo cif parsed! num_anims={num_anims}, frame_counts={anim_frame_counts}")

def render_lobo(anim_id, dir_id, frame_id, size=64):
    var6 = anim_offsets[anim_id] + 1
    max_f = anim_frame_counts[anim_id]
    if frame_id >= max_f or frame_id < 0: frame_id = 0
    for _ in range(frame_id):
        for _ in range(4):
            np = table_b[var6]; var6 += 1 + np * 4
    for _ in range(dir_id - 1):
        np = table_b[var6]; var6 += 1 + np * 4
    np = table_b[var6]; var6 += 1
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    center_x, center_y = size // 2, size // 2 + 10
    for _ in range(np):
        b0 = table_b[var6]; b1 = table_b[var6 + 1]
        dx = struct.unpack('b', bytes([table_b[var6 + 2]]))[0]
        dy = struct.unpack('b', bytes([table_b[var6 + 3]]))[0]
        var6 += 4
        layer_idx = (b0 & 127) + (0 if (b0 >> 7 == 0) else num_layers)
        slice_idx = b1
        if layer_idx < len(all_layers) and slice_idx < len(all_layers[layer_idx]):
            slice_img = all_layers[layer_idx][slice_idx]
            canvas.paste(slice_img, (center_x + dx, center_y + dy), slice_img)
    return canvas

# Render Lobo Idle in 4 directions
strip = Image.new('RGBA', (64 * 4, 64), (0, 0, 0, 0))
for d in range(1, 5):
    img = render_lobo(0, d, 0)
    strip.paste(img, ((d - 1) * 64, 0))
strip.save('tools/test_lobo_authentic_4dirs.png')
print("Successfully rendered authentic Lobo to tools/test_lobo_authentic_4dirs.png")
