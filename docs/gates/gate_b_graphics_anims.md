# Puerta de Aprobación — Fundamentos Gráficos y Animaciones (Gate B)

Documento de control para confirmar que las animaciones representativas, la escala, los puntos de apoyo, las colisiones y la integración de recursos funcionan de manera precisa en Godot antes de integrar el recorrido completo.

**Estado actual:** `APPROVED`

**Estados válidos:** `PENDING` | `REJECTED` | `APPROVED`

---

## 1. Criterios de Aceptación
1. Cero discrepancias criptográficas entre los sprites cargados en Godot y las capas maestras del JAR (`hero/h1` Asesino).
2. Puntos de apoyo (pivote) unificados y comprobados en pies (`Vector2(0, -100)` en lienzo 256×320 a 4x).
3. Ciclos de animación completos verificados sin recortes, desalineación de armas ni caídas a reposo durante la marcha.
4. Mapeo estricto del ciclo de marcha: 4 fotogramas base J2ME repetidos dos veces consecutivas (`i % 4`) para formar los 8 archivos a 10 FPS.
5. Ataques Combo 1 y Combo 2 con tajos VFX integrados y finalización autónoma con retorno limpio a reposo.
6. Suite de validación en Godot (`AnimReview.tscn`) sin fallos y con reporte fiable.

## 2. Evidencias Verificadas
- `godot/anim_captures/provenance_audit.json`: 134/134 sprites auditados píxel a píxel (100% coincidencia, 0 discrepancias).
- `godot/anim_captures/anim_validation_results.json`: 1,552 aserciones totales (1,548 PASS, 0 FAIL, 4 NOT TESTED justificadas).
- `docs/diagnostics/KNOWN_GRAPHICS_ISSUES.md`: Informe completo de causas raíz y resolución técnica.
- Evidencias visuales en el motor:
  - Hoja de contacto completa: `godot_real_contact_sheet.png`
  - Grabación de marcha en 4 direcciones: `godot_lucian_gameplay_recording.gif`
  - Grabación de combos de combate: `godot_lucian_attack_combo_recording.gif`

## 3. Dictamen
- **Aprobado el 2026-10-16.** Los fundamentos gráficos y de animación de Lucian cumplen con los requisitos de fidelidad e integración técnica.
