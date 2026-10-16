"""
tests/test_coverage_updater.py — Pruebas automatizadas de seguridad para tools/update_coverage.py.
Verifica:
  1. Detección y rechazo de IDs duplicados sin sobrescritura del CSV.
  2. Detección y rechazo de filas con campo 'id' vacío o ausente.
  3. Creación de copia de seguridad (.bak) previa a cualquier modificación.
  4. Preservación íntegra de filas manuales existentes en ejecuciones exitosas.
"""

import csv
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from tools.update_coverage import HEADER, update_coverage, validate_and_load_existing_coverage


class TestCoverageUpdaterSecurity(unittest.TestCase):

    def setUp(self):
        self.test_dir = Path(tempfile.mkdtemp(prefix="hlz_test_coverage_"))

    def tearDown(self):
        shutil.rmtree(self.test_dir, ignore_errors=True)

    def _write_csv(self, filename: str, rows: list) -> Path:
        target = self.test_dir / filename
        with open(target, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=HEADER)
            writer.writeheader()
            for r in rows:
                writer.writerow(r)
        return target

    def test_duplicate_id_rejected_without_loss(self):
        """Demuestra que un CSV con IDs duplicados se rechaza con código 1 y no se modifica."""
        rows = [
            {
                "categoria": "clase", "id": "CLASE_ASESINO", "nombre_original": "Asesino",
                "region": "Global", "tipo_recurso": "clase_jugable", "referencia_disponible": "si",
                "estado_logica": "implementado", "estado_arte": "validado_tecnicamente",
                "estado_validacion": "verificado_contra_original", "estado_aprobacion": "APPROVED_GATE_B",
                "fuente_referencia": "ref.jpg", "notas": "Fila 1 legítima"
            },
            {
                "categoria": "clase", "id": "CLASE_ASESINO", "nombre_original": "Asesino Duplicado",
                "region": "Global", "tipo_recurso": "clase_jugable", "referencia_disponible": "si",
                "estado_logica": "interpretado", "estado_arte": "extraido_png",
                "estado_validacion": "pendiente", "estado_aprobacion": "PENDING_GATE_D",
                "fuente_referencia": "ref2.jpg", "notas": "Fila 2 duplicada ilegal"
            }
        ]
        csv_path = self._write_csv("duplicate_coverage.csv", rows)
        initial_content = csv_path.read_text(encoding="utf-8")

        # Debe lanzar ValueError o retornar código 1
        with self.assertRaises(ValueError):
            validate_and_load_existing_coverage(csv_path)

        code = update_coverage(csv_path=csv_path, backup=False)
        self.assertEqual(code, 1, "update_coverage debe retornar código 1 al detectar duplicados")

        # El archivo original NO debe haber sido modificado
        final_content = csv_path.read_text(encoding="utf-8")
        self.assertEqual(initial_content, final_content, "El CSV con duplicados no debe ser alterado ni perder filas")

    def test_missing_or_empty_id_rejected(self):
        """Demuestra que filas con 'id' vacío son rechazadas y abortan la operación."""
        rows = [
            {
                "categoria": "sistema", "id": "", "nombre_original": "Sin ID",
                "region": "Global", "tipo_recurso": "sistema_motor", "referencia_disponible": "si",
                "estado_logica": "implementado", "estado_arte": "no_aplica",
                "estado_validacion": "validado_tecnicamente", "estado_aprobacion": "PENDING_GATE_D",
                "fuente_referencia": "", "notas": ""
            }
        ]
        csv_path = self._write_csv("empty_id_coverage.csv", rows)
        initial_content = csv_path.read_text(encoding="utf-8")

        code = update_coverage(csv_path=csv_path, backup=False)
        self.assertEqual(code, 1, "update_coverage debe retornar código 1 con IDs vacíos")
        self.assertEqual(csv_path.read_text(encoding="utf-8"), initial_content)

    def test_backup_created_on_safe_update(self):
        """Demuestra que se crea una copia de seguridad .bak antes de modificar el CSV."""
        rows = [
            {
                "categoria": "info", "id": "MIDLET", "nombre_original": "Heroes Lore Zero",
                "region": "Global", "tipo_recurso": "midlet_j2me", "referencia_disponible": "si",
                "estado_logica": "verificado_contra_original", "estado_arte": "referencia_preparada",
                "estado_validacion": "verificado_contra_original", "estado_aprobacion": "APPROVED_GATE_A",
                "fuente_referencia": "Heroes Lore.jar", "notas": "v4.4.45"
            }
        ]
        csv_path = self._write_csv("valid_coverage.csv", rows)
        initial_content = csv_path.read_text(encoding="utf-8")

        code = update_coverage(csv_path=csv_path, backup=True)
        self.assertEqual(code, 0, "update_coverage debe retornar código 0 en CSV válido")

        backup_file = csv_path.with_suffix(".csv.bak")
        self.assertTrue(backup_file.exists(), "Debe existir la copia de seguridad .bak")
        self.assertEqual(backup_file.read_text(encoding="utf-8"), initial_content, "El backup debe ser idéntico al original")

    def test_preserves_custom_manual_rows(self):
        """Demuestra que filas manuales (no presentes en base_rows ni mapas) se preservan intactas."""
        rows = [
            {
                "categoria": "mision_historia", "id": "QUEST_001_INICIO", "nombre_original": "El despertar en Silverleaf",
                "region": "Region 1 - Aldea Silverleaf y Alrededores", "tipo_recurso": "evento_historia", "referencia_disponible": "si",
                "estado_logica": "interpretado", "estado_arte": "no_aplica",
                "estado_validacion": "pendiente_fase5", "estado_aprobacion": "PENDING_GATE_D",
                "fuente_referencia": "t/m/0.tdf", "notas": "Misión creada manualmente por diseño narrativo"
            }
        ]
        csv_path = self._write_csv("manual_row_coverage.csv", rows)
        code = update_coverage(csv_path=csv_path, backup=False)
        self.assertEqual(code, 0)

        # Verificar que la fila manual sigue existiendo en el CSV actualizado
        updated_rows = validate_and_load_existing_coverage(csv_path)
        self.assertIn("QUEST_001_INICIO", updated_rows)
        self.assertEqual(updated_rows["QUEST_001_INICIO"]["notas"], "Misión creada manualmente por diseño narrativo")


if __name__ == "__main__":
    unittest.main()
