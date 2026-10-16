# Puerta de Aprobación — Primer Recorrido Completo Integrado (Gate C)

Documento de control técnico que valida la integración completa de todos los sistemas fundamentales (Menú, Selección de personaje, Prólogo, Mapa, Combate, Persistencia) en un único flujo de juego continuo sin fallos, previo a la revisión humana (Gate D).

**Estado actual:** `PENDING`

**Estados válidos:** `PENDING` | `REJECTED` | `APPROVED`

---

## 1. Criterios de Aceptación
1. El juego arranca en `scenes/Main.tscn` mostrando el Menú Principal con navegación completa por mando y teclado (T5.A).
2. Se accede a la Selección de Personaje, se elige una clase inicial válida y los atributos se transfieren al jugador (T5.B).
3. Se reproduce el Prólogo narrativo original y las transiciones iniciales sin requerir comandos de depuración (T5.C).
4. El jugador se desplaza por Aldea Silverleaf (`m/m/00`), colisiona con el entorno y conversa con los NPCs iniciales (T5.D).
5. Se ejecuta el primer combate completo contra un enemigo canónico en la salida del mapa con daño, animaciones y drops (T5.E).
6. Se guarda la partida en disco (`user://saves/`), se sale al menú principal o se reinicia el juego, y se carga exitosamente restaurando posición, stats e inventario (T5.F).
7. La suite de pruebas de integración E2E se ejecuta en modo headless y gráfico sin arrojar errores ni advertencias críticas (T5.G).

## 2. Evidencias Requeridas
- Script de prueba de integración de flujo E2E automatizado (`tests/test_walkthrough_e2e.py` o escena Godot `scenes/WalkthroughTest.tscn`).
- Capturas de pantalla secuenciales de cada hito del recorrido.
- Registro de telemetría de guardado y carga confirmando paridad de estado serializado.

## 3. Dictamen
- **Pendiente:** T5.A a T5.G en fase de planificación e implementación inicial.
