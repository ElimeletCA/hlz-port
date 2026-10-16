import zipfile, struct

z = zipfile.ZipFile('input/Heroes Lore Zero 360x640 Spanish.jar')
edf = z.read('en/edf')

off = 0
rec_idx = 0
while off + 2 <= len(edf):
    rlen = struct.unpack('>H', edf[off:off+2])[0]
    rec = edf[off+2:off+2+rlen]
    if len(rec) > 0:
        nlen = rec[0]
        name = rec[1:1+nlen].decode('iso-8859-1', errors='ignore')
        if 'lobo' in name.lower() or 'wolf' in name.lower():
            k = rec[1+nlen]
            etype = rec[2+nlen]
            lid = rec[3+nlen]
            d = list(rec[8+nlen:14+nlen])
            print(f"Record {rec_idx}: name='{name}', k={k}, etype={etype}, lid={lid}, d={d}")
    off += 2 + rlen
    rec_idx += 1

print(f"Total records in edf: {rec_idx}")
