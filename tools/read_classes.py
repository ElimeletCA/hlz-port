import zipfile

z = zipfile.ZipFile('input/Heroes Lore Zero 360x640 Spanish.jar')
data = z.read('t/j.tdf')
off = 0
idx = 0
while off < len(data):
    l = data[off]
    off += 1
    if off + l <= len(data):
        s = data[off:off+l].decode('utf-8', errors='ignore')
        print(f'{idx}: "{s}"')
        off += l
        idx += 1
    else:
        break
