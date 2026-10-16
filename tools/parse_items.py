import zipfile, struct

z = zipfile.ZipFile('input/Heroes Lore Zero 360x640 Spanish.jar')

def get_record(path, idx):
    data = z.read(path)
    off = 0
    for _ in range(idx):
        rlen = struct.unpack('>h', data[off:off+2])[0]
        off += 2 + rlen
    rlen = struct.unpack('>h', data[off:off+2])[0]
    return data[off+2:off+2+rlen]

for itm_id in [0, 1, 2, 6, 7]:
    rec = get_record(f'itm/{itm_id:02d}', 0)
    name_len = rec[0]
    name = rec[1:1+name_len].decode('utf-8', errors='ignore')
    off = 1 + name_len
    # in ai.java:
    # super.a reads name, then:
    # this.b = var1[var2++];
    # this.c = var1[var2++];
    # this.a = rpg.f.a(var1, var2); var2 += 4; // price
    # in bx.java:
    # this.d = var1[var2++];
    # this.e = var1[var2++];
    # this.f = var1[var2++];
    # this.g = var1[var2++]; // VISUAL GRAPHIC INDEX!
    b_val = rec[off]; c_val = rec[off+1]
    price = struct.unpack('>i', rec[off+2:off+6])[0]
    bx_d = rec[off+6]
    bx_e = rec[off+7]
    bx_f = rec[off+8]
    bx_g = rec[off+9]
    print(f'itm/{itm_id:02d} rec 0: "{name}"')
    print(f'  type={itm_id}, visual_g={bx_g} -> /hero/w/{itm_id}{bx_g:02d}')
