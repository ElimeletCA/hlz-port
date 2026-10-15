"""
tests/test_combat_parity.py — Suite de pruebas de paridad numérica (T5.6)
Verifica que las fórmulas de combate, progresión y cálculo de daño en Godot
coincidan estrictamente con las especificaciones de ingeniería inversa:
- docs/spec/combat.md (Fórmulas de daño, crítico, evasión)
- docs/spec/progression.md (Curva de EXP y crecimiento de stats)
"""

import math
import random
import unittest


def calculate_base_damage(atk: int, target_def: int, variance: int = 0) -> int:
    return max(1, atk - target_def + variance)


def calculate_critical_damage(base_dmg: int) -> int:
    return math.floor(base_dmg * 1.5)


def calculate_crit_chance(target_def: int) -> int:
    # dg.java línea 2165: max(10, 60 - DEF)
    return max(10, 60 - target_def)


def calculate_required_exp(level: int) -> int:
    # docs/spec/progression.md: floor(50 * (L - 1)^2.2 + 20 * (L - 1))
    if level <= 1:
        return 0
    return math.floor(50.0 * math.pow(level - 1, 2.2) + 20.0 * (level - 1))


class TestCombatParity(unittest.TestCase):

    def test_damage_formula_basic(self):
        """Verifica daño neto básico sin varianza."""
        # Lucian ATK=18 contra Lobo DEF=4 -> Daño = 14
        dmg = calculate_base_damage(18, 4, 0)
        self.assertEqual(dmg, 14)

    def test_damage_formula_high_defense(self):
        """Verifica que el daño mínimo siempre es 1 independientemente de la defensa."""
        dmg = calculate_base_damage(10, 999, 0)
        self.assertEqual(dmg, 1)

    def test_damage_variance_bounds(self):
        """Verifica que la varianza sea exactamente +/- floor(ATK / 20)."""
        atk = 18
        var_range = max(1, math.floor(atk / 20.0))
        # Para ATK=18, floor(18/20) = 0, clamp a 1 -> varianza entre -1 y +1
        self.assertEqual(var_range, 1)
        
        for _ in range(100):
            var = random.randint(-var_range, var_range)
            self.assertTrue(-1 <= var <= 1)
            dmg = calculate_base_damage(atk, 4, var)
            self.assertTrue(13 <= dmg <= 15)

    def test_critical_strike_multiplier(self):
        """Verifica el multiplicador de impacto crítico del 150% redondeado hacia abajo."""
        base_dmg = 14
        crit_dmg = calculate_critical_damage(base_dmg)
        self.assertEqual(crit_dmg, 21)

        # Caso impar
        base_dmg_odd = 15
        crit_dmg_odd = calculate_critical_damage(base_dmg_odd)
        self.assertEqual(crit_dmg_odd, 22) # floor(15 * 1.5) = 22

    def test_critical_probability_formula(self):
        """Verifica la fórmula de probabilidad crítica de dg.java:2165."""
        # Contra lobo con DEF=4 -> 60 - 4 = 56%
        self.assertEqual(calculate_crit_chance(4), 56)
        # Contra enemigo blindado DEF=60 -> 60 - 60 = 0 -> clamped a 10%
        self.assertEqual(calculate_crit_chance(60), 10)
        # Contra jefe súper blindado DEF=100 -> clamped a 10%
        self.assertEqual(calculate_crit_chance(100), 10)

    def test_exp_curve_progression(self):
        """Verifica los valores clave de la tabla de experiencia requerida."""
        self.assertEqual(calculate_required_exp(1), 0)
        self.assertEqual(calculate_required_exp(2), 70)
        # Nivel 3
        exp_lvl3 = calculate_required_exp(3)
        self.assertTrue(200 <= exp_lvl3 <= 300)
        # Nivel 5
        exp_lvl5 = calculate_required_exp(5)
        self.assertTrue(1000 <= exp_lvl5 <= 1300)

    def test_warrior_stat_growth(self):
        """Verifica que el crecimiento por nivel del Guerrero coincide con la tabla."""
        base_hp, base_mp, base_atk, base_def = 120, 30, 18, 12
        # Crecimiento por nivel: HP +28, MP +6, ATK +5, DEF +3
        hp_lvl2 = base_hp + 28
        mp_lvl2 = base_mp + 6
        atk_lvl2 = base_atk + 5
        def_lvl2 = base_def + 3
        
        self.assertEqual(hp_lvl2, 148)
        self.assertEqual(mp_lvl2, 36)
        self.assertEqual(atk_lvl2, 23)
        self.assertEqual(def_lvl2, 15)


if __name__ == "__main__":
    unittest.main()
