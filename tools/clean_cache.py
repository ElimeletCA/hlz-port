import os

valid_ctex = set()
art_dir = 'godot/art_samples'
imp_dir = 'godot/.godot/imported'

for f in os.listdir(art_dir):
    if f.endswith('.import'):
        with open(os.path.join(art_dir, f), 'r') as fl:
            for line in fl:
                if line.startswith('path='):
                    target = line.split('"')[1].replace('res://.godot/imported/', '')
                    valid_ctex.add(target)
                    valid_ctex.add(target.replace('.ctex', '.md5'))

removed = 0
for f in os.listdir(imp_dir):
    if (f.endswith('.ctex') or f.endswith('.md5')) and f not in valid_ctex:
        for prefix in ['hero_', 'map_', 'npc_', 'enemy_', 'prop_', 'tile_', 'vfx_']:
            if f.startswith(prefix):
                p = os.path.join(imp_dir, f)
                try:
                    os.remove(p)
                    print(f"Removed stale cache: {f}")
                    removed += 1
                except Exception as e:
                    print(f"Error removing {f}: {e}")

print(f"Total stale cache files removed: {removed}")
