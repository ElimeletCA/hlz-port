import zipfile, struct

z = zipfile.ZipFile('input/Heroes Lore Zero 360x640 Spanish.jar')
ndf = z.read('en/ndf')

# Let's inspect ndf structure
# In e.java:547: byte[] var54 = rpg.c.a("/en/ndf");
# In ah.java: lines loading ndf
lines = open('reverse/decompiled/ah.java', errors='ignore').readlines()
for i, l in enumerate(lines):
    if 'ndf' in l or 'np' in l:
        print(''.join(lines[max(0, i-5):min(len(lines), i+25)]))
        break
