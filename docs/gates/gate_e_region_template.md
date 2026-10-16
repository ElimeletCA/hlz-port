# Puerta de Aprobación Regional — Plantilla de Región (Gate E)

Plantilla de control de calidad aplicable a cada región o capítulo de la historia original durante la Fase 6. Ninguna región se considerará terminada mientras existan errores bloqueantes, transiciones rotas o dependencias narrativas sin resolver.

**Región:** `[NOMBRE_DE_REGION]`  
**Capítulo / Rango de Mapas:** `[MAPAS_INCLUIDOS]`  
**Estado:** `PENDING` | `REJECTED` | `APPROVED`

---

## 1. Lista de Comprobación de la Región (12 Puntos Obligatorios)

- [ ] **1. Mapas y Conexiones:** Todos los mapas de la región cargan correctamente y los portales bidireccionales funcionan sin errores.
- [ ] **2. Tilesets y Recursos Gráficos:** Tilesets en 4x con colisiones verificadas, sin costuras visibles ni desajustes de capas.
- [ ] **3. Personajes y NPCs:** Todos los NPCs de la zona colocados en sus coordenadas canónicas con orientaciones y diálogos verificados.
- [ ] **4. Diálogos y Eventos:** Textos extraídos de `.tdf` sin caracteres truncados ni dependencias de flags rotas.
- [ ] **5. Misiones y Progresión:** Marcadores de misión (`mmi`) coherentes y actualización de estado en bitset.
- [ ] **6. Enemigos y Variantes:** Spawns de monstruos con atributos, rangos de aggro, animaciones y drops originales.
- [ ] **7. Objetos, Equipo y Tiendas:** Forjas, vendedores y cofres configurados con tablas de precios e inventario original.
- [ ] **8. Combates Especiales y Jefes:** Encuentros de jefes con fases, patrones, cinemáticas y recompensas activas.
- [ ] **9. Minijuegos y Contenido Opcional:** Minijuegos de la región (si aplican) jugables con mando y teclado.
- [ ] **10. Integración Continua:** El progreso acumulado desde regiones anteriores se preserva sin desajustes.
- [ ] **11. Pruebas y Revisión de Errores:** Ejecución limpia de `tools/verify_region.py` en modo headless sin excepciones.
- [ ] **12. Aprobación de la Región:** Sesión de juego humana verificando la sensación, dificultad y coherencia de la zona.

---

## 2. Evidencias y Pruebas
- Captura general de cada mapa de la región en ejecución.
- Registro de cobertura en `docs/coverage.csv` actualizado con estado `verificado_en_motor`.
