"""
tools/README.md — Guía de herramientas del proyecto Heroes Lore: Zero Port
Actualizar este archivo al añadir o cambiar herramientas.
"""

# ──────────────────────────────────────────────────────────────
# RUTAS DE HERRAMIENTAS
# Editar si se mueven los archivos o cambia la versión.
# ──────────────────────────────────────────────────────────────
import subprocess, sys, os
from pathlib import Path

TOOLS_DIR  = Path(__file__).parent
REPO_ROOT  = TOOLS_DIR.parent

GODOT_EXE  = Path(r"C:\Proyecto HLZ\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe")
GODOT_CON  = Path(r"C:\Proyecto HLZ\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe")
GODOT_PROJ = REPO_ROOT / "godot"

VINEFLOWER = TOOLS_DIR / "vineflower-1.12.0.jar"
FLUIDSYNTH = TOOLS_DIR / "fluidsynth" / "fluidsynth-v2.6.1-win10-x64-cpp11" / "bin" / "fluidsynth.exe"
FREEJ2ME   = TOOLS_DIR / "freej2me-plus" / "freej2me_plus.jar"

# Krita 5.3.4.1 — instalado manualmente en Program Files
def _find_krita() -> Path | None:
    candidates = [
        Path(r"C:\Program Files\Krita (x64)\bin\krita.exe"),  # ruta verificada 2026-10-14
        Path(r"C:\Program Files\Krita\bin\krita.exe"),
    ]
    for c in candidates:
        if c.exists():
            return c
    # Intentar desde PATH
    try:
        result = subprocess.run(["where", "krita"], capture_output=True, text=True)
        if result.returncode == 0:
            return Path(result.stdout.strip().splitlines()[0])
    except Exception:
        pass
    return None

KRITA = _find_krita()


def check_all():
    """Verifica que todas las herramientas están disponibles."""
    tools = {
        "Godot (GUI)":    GODOT_EXE,
        "Godot (console)":GODOT_CON,
        "Vineflower JAR": VINEFLOWER,
        "FluidSynth":     FLUIDSYNTH,
        "FreeJ2ME-Plus":  FREEJ2ME,
        "Krita":          KRITA,
    }
    all_ok = True
    for name, path in tools.items():
        if path and Path(path).exists():
            print(f"  [OK] {name}: {path}")
        else:
            print(f"  [!!] {name}: NO ENCONTRADO (ruta: {path})")
            all_ok = False
    return all_ok


if __name__ == "__main__":
    print("=== Verificación de herramientas ===")
    ok = check_all()
    sys.exit(0 if ok else 1)
