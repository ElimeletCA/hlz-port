# Puerta de Aprobación Humana — Primer Recorrido Completo (Gate D)

Documento canónico de aprobación formal del Vertical Slice e integración del primer recorrido antes de desbloquear la producción masiva (Fase 6).

**Estado actual:** `PENDING`

**Estados válidos:** `PENDING` | `REJECTED` | `APPROVED`

> [!CAUTION]
> **PUERTA BLOQUEANTE:** La producción masiva de mapas, personajes, enemigos, efectos y escenarios (Fase 6) está **ESTRICTAMENTE BLOQUEADA** hasta que este documento registre el estado `APPROVED`.
> El agente de IA **NO PUEDE** modificar este estado a `APPROVED` bajo ninguna circunstancia. La aprobación debe ser otorgada explícitamente por la persona responsable del proyecto.

---

## 1. Criterios de Aceptación para Evaluación

Para que este hito pueda presentarse a revisión humana, el primer recorrido debe ejecutarse de forma continua sin depender de herramientas de desarrollo, escenas aisladas de prueba ni teletransportes:

1. **Flujo de Ejecución Continuo:**
   - **Menú Principal (T5.A):** Permite iniciar nueva partida, continuar partida guardada, ajustar opciones básicas, navegar con mando y teclado, y salir limpiamente.
   - **Selección de Personaje (T5.B):** Permite seleccionar las clases iniciales confirmadas por el original (Asesino, Guerrero, Caballero, Pistolero), reflejando sus atributos y sprite correspondientes.
   - **Prólogo y Eventos Narrativos (T5.C):** Introducción y diálogos iniciales según el orden verificado en el juego original.
   - **Inicio de la Aventura y Primer Mapa (T5.D):** Llegada autónoma a Aldea Silverleaf (`m/m/00`), movimiento, colisiones, orientación y diálogo con NPCs.
   - **Primer Combate Completo (T5.E):** Enfrentamiento contra un enemigo real en la zona exterior, recibiendo daño, ejecutando combos, aplicando fórmulas de combate originales y recogiendo recompensas.
   - **Persistencia y Continuación (T5.F):** Guardado de partida en disco, regreso al menú principal o reinicio, y continuación exitosa restaurando posición, atributos e inventario.
   - **Prueba Extremo a Extremo (T5.G):** Recorrido completo sin excepciones ni errores de depuración.

2. **Criterios de Calidad Técnica y Artística:**
   - **Fidelidad y Legibilidad Visual 2D:** Estilo 2D ilustrado y remasterizado a 4x pixel-perfect respetando las proporciones, paletas e identidad original.
   - **Calidad de Animación:** Animaciones fluidas de Lucian (reposo a 6 FPS, marcha a 10 FPS, combo a 14 FPS) sin desajustes de armas, saltos de posición ni recortes.
   - **Cámara y Encuadre:** Variante B cenital ligeramente elevada aprobada, con zoom 2.0x, offset vertical (0, -80 px) y viñeteado ambiental en bordes.
   - **Control y Sensación Jugable:** Soporte nativo de mando como primera opción y teclado, con zona muerta configurada y respuesta inmediata.
   - **Rendimiento:** 60 FPS estables medidos en el equipo disponible en perfiles Bajo, Medio y Alto.

---

## 2. Lista de Comprobación del Hito (T5.H)

- [ ] **T5.A** · Menú principal operativo e integrado
- [ ] **T5.B** · Pantalla de selección de personaje con persistencia de clase
- [ ] **T5.C** · Prólogo narrativo original ejecutable sin comandos especiales
- [ ] **T5.D** · Exploración de Aldea Silverleaf (mapa, colisiones, NPCs y diálogos)
- [ ] **T5.E** · Primer combate completo con animaciones, hitboxes, daño y drop
- [ ] **T5.F** · Sistema de guardado y carga persistente verificado desde menú
- [ ] **T5.G** · Prueba de extremo a extremo (E2E) aprobada sin intervención manual
- [ ] **T5.H** · Demostración jugable probada por la persona responsable

---

## 3. Registro de Decisiones y Revisiones

| Fecha | Estado | Responsable | Observaciones / Defectos Detectados |
|---|---|---|---|
| 2026-10-14 | PENDING | Antigravity | Inicio del proyecto. Fundamentos en desarrollo. |
| 2026-10-15 | REJECTED | Usuario | Rechazado enfoque de arte IA desalineado. Solicitada reconstrucción fiel de recursos originales 4x y corrección de animaciones de Lucian. |
| 2026-10-16 | PENDING | Antigravity | Animaciones de Lucian auditadas y validadas al 100% (1,548 PASS). Reorganización hacia el primer recorrido integrado E2E en curso. |

---

## 4. Instrucciones para la Persona Responsable

Para otorgar la aprobación de este hito:
1. Ejecute el juego desde el lanzador principal `godot/scenes/Main.tscn` (o ejecutable exportado).
2. Complete la secuencia: *Menú -> Nueva Partida -> Selección -> Prólogo -> Silverleaf -> Combate -> Guardado -> Salir -> Continuar*.
3. Si el resultado es satisfactorio, modifique el campo `Estado actual` a `APPROVED` e indique la fecha y notas de aprobación en la tabla superior.
