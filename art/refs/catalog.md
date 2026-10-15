# Catálogo de Referencias Artísticas y Criterios de Rediseño 2D (T2.8)

**Proyecto:** Heroes Lore: Zero — Port para PC en Godot 4.7.2  
**Documento:** Referencias extraídas del original vs. Directrices estéticas de rediseño  
**Fuentes analizadas:** 460 contenedores `.mpm` (3.199 frames extraídos en `out/sprites/`), 141 mapas `.m` renderizados en `out/renders/`, capturas de referencia del emulador en `docs/reference/` y especificación visual aprobada en `art/STYLE.md`.

---

## 1. Metodología de Separación: Hechos vs. Interpretaciones

Para preservar la esencia y fidelidad del juego original sin arrastrar las limitaciones técnicas de la plataforma J2ME de 2008, este catálogo categoriza cada elemento en dos columnas analíticas:
- **Hecho técnico observado:** Datos exactos deducidos del `.jar`, la ingeniería inversa, paletas indexadas, resoluciones originales y comportamiento en emulador.
- **Directriz de rediseño 2D:** Criterios estéticos para Godot 4.7 Compatibility con resolución nativa 1920×1080, inspirados en la dirección ilustrada y cenital aprobada en `art/STYLE.md` (atmósfera, profundidad y lectura clara, sin clonar assets externos).

---

## 2. Héroe Protagonista (Lucian) y Clases

| Parámetro | Hecho Técnico Observado (Original J2ME) | Directriz de Rediseño 2D (Godot PC) |
|---|---|---|
| **Identidad visual** | Pelo rojo vivo puntiagudo, armadura azul oscuro/metálica con hombreras doradas. Complexión esbelta pero atlética. | Mantener inalterable el pelo rojo característico y el contraste azul/dorado de la armadura para reconocimiento instantáneo. |
| **Dimensiones base** | 24×32 píxeles por frame de personaje en resolución nativa 360×640. | Altura visual de ~96 a 128 píxeles en resolución base 1920×1080 (3x a 4x el detalle original). |
| **Clase 0: Guerrero** | Mandoble a dos manos con filo azul claro y guarda dorada. Animación de tajo amplio con arco frontal. | Silueta pesada, tajo con efecto de estela semitransparente pintada y retroceso de peso en el golpe. |
| **Clase 1: Caballero** | Espada corta de una mano y escudo metálico alargado. Postura defensiva erguida. | Escudo visible y con sombreado de volumen; postura de guardia firme con animación de bloqueo reactiva. |
| **Clase 2: Asesino** | Doble empuñadura de dagas. Ropa ligera y ágil. Cadencia de ataque rápida (4 frames). | Silueta aerodinámica, dagas gemelas con brillos especulares; animación de estocada doble vertiginosa. |
| **Clase 3: Pistolero** | Dos armas de fuego cortas (revólveres/pistolas). Disparo frontal a distancia con fogonazo de 2 frames. | Postura de pistolero dinámico con fogonazos estilizados en spritesheet y partículas de humo tenue. |
| **Clases Secretas (NG+)** | **Elemental:** Magia violeta/púrpura. **Gunblader:** Híbrido espada-pistola con tono cian/turquesa. | Efectos elementales con gradientes ricos; diseño de filo-pistola con acabados mecánicos limpios. |
| **Direcciones de movimiento** | 4 direcciones canónicas (Norte, Sur, Este, Oeste). Movimiento diagonal usa el frame lateral. | Mantener las 4 direcciones con 8 direcciones de lectura en la cámara cenital si el control lo requiere. |
| **Ciclos de animación** | 3 cuadros para caminar (paso izq, neutro, paso der); 3-4 cuadros para combo de ataque; 1 cuadro de impacto/dolor. | Ampliar a 6-8 cuadros por ciclo de animación para suavidad a 60 FPS sin perder el ritmo snappy de respuesta. |

---

## 3. Enemigos y Familias de Monstruos (`en/0` a `en/53`)

Total confirmado: **54 carpetas de enemigos y variantes** (963 frames en `out/sprites/en/`).

| Familia / Tipo | Hecho Técnico Observado | Directriz de Rediseño 2D |
|---|---|---|
| **Fauna menor (lobos, jabalíes, murciélagos)** | Sprites pequeños (~20×20 px). Ataques lineales rápidos embistiendo al héroe. | Textura de pelaje estilizada, ojos brillantes, animación previa de anticipación (telegraph) clara. |
| **Flora agresiva (Carnívora)** | Planta inmóvil con fauces y espinas. Ataque en ráfaga frontal o escupiendo proyectiles venenosos. | Raíces incrustadas en el suelo con blending suave sobre el bioma; fauces con apertura amenazante. |
| **No-muertos (Jardín de Huesos)** | Esqueletos con espadas oxidadas, zombis lentos. Animaciones desarticuladas. | Sombras profundas en cuencas, texturas de hueso desgastado, desmoronamiento de piezas al morir. |
| **Guardias / Soldados (Fortaleza del Sur)** | Humanoides con armaduras completas, lanzas y alabardas. Patrullas en cuadrícula. | Siluetas imponentes con heráldica de la Fortaleza, brillo metálico ilustrado en armaduras. |
| **Bestias Mayores (Quimera, Perro del Infierno)** | Sprites grandes (~48×48 px). Embestidas con fuego y mordiscos con área de efecto. | Escala imponente (~160×160 px en PC), garras que rasgan el suelo, efectos de fuego volcánico. |
| **Jefes Principales (Anthony, Alicia, Aquila, Timoros, Dios Gigante)** | Sprites únicos con fases de ataque, auras de invulnerabilidad momentánea y diálogos previos. | Proporciones estilizadas pero legibles, auras visuales por capas, animación de derrota dramática. |

---

## 4. NPCs y Poblaciones de Localizaciones

| Localización | Arquetipos de NPC Observados | Tratamiento de Rediseño |
|---|---|---|
| **Aldea Silverleaf** | Niños y cuidadoras del Orfanato, herrero local, posadero de dos pisos, ancianos de la aldea. | Paleta cálida, ropa rústica de lana y cuero, expresiones amables en retratos ilustrados. |
| **Aldea Melon** | Guardias de la Oficina del Alguacil, vigía del Faro, pescadores locales. | Ropa marítima, tonos azules marinos y marrones curtidos por el viento costero. |
| **Ciudad Humming** | Bibliotecarios, maestros del Centro de Profesión, refinadores, guardias urbanos. | Ropa académica y de gremio más elaborada; contraste urbano sofisticado. |
| **Ciudad Ciruelo** | Mercaderes de tienda, soldados imperiales, carceleros de la prisión subterránea. | Toques orientales/elegantes según la arquitectura de Ciruelo; guardias con estética marcial. |

---

## 5. Armas y Equipo Superpuesto (`hero/w/`)

- **Hecho técnico:** En el motor J2ME original, las armas no están pegadas permanentemente al cuerpo del sprite de Lucian, sino que se dibujan como capas superpuestas mediante coordenadas relativas (`ba.java`). Esto permitía cambiar el arma equipada sin rehacer todos los sprites del personaje.
- **Directriz de rediseño:** En Godot 4.7, replicar este desacoplamiento arquitectónico mediante un nodo `Sprite2D` hijo de Lucian o puntos de anclaje (`Marker2D` / Sockets) para armas, permitiendo que cualquier espada, daga o pistola ilustrada se monte dinámicamente con su capa de profundidad correcta (`Z-index`).

---

## 6. Objetos de Escenario y Props (`m/ob0` a `m/ob4`)

Total confirmado: **170 frames de objetos interactivos y decorativos**.
- **Cofres de tesoro:** Dos estados indispensables: cerrado (1 frame) y abierto (1 frame). En el rediseño, añadir pequeña animación de apertura de 3 cuadros con resplandor dorado sutil.
- **Barriles, cajas y jarrones:** Rompibles al recibir ataques del héroe. Crear partículas de astillas y fragmentos de cerámica con `CPUParticles2D`.
- **Portales y transiciones:** Runa o puerta luminosa con pulsación cíclica de transparencia.
- **Almonedas y mostradores:** Integrados a la perspectiva cenital con superficie superior visible para lectura de objetos sobre ellos.

---

## 7. Tilesets y Biomas (`m/t00` a `m/t34`)

Los 35 tilesets del juego original cubren los siguientes biomas fundamentales:
1. **Bosque y Pradera Rural (Silverleaf):** Hierba verde natural, senderos de tierra compacta, cercas de madera y techos de teja roja.
2. **Urbano y Portuario (Humming / Melon):** Adoquines de piedra grisácea, muelles de tablones de madera, agua marina con olas suaves, edificios de cantería.
3. **Cueva y Mina Subterránea:** Paredes de roca escarpada, estalagmitas, vías de vagoneta, charcos de agua estancada.
4. **Pantano Oscuro:** Lodo verdoso, aguas pantanosas turbias, vegetación marchita, niebla superficial baja.
5. **Jardín de Huesos:** Tierra cenicienta/árida, osamentas gigantes semienterradas, lápidas y monumentos funerarios.
6. **Fortaleza y Prisiones:** Suelo de baldosas de piedra pulida, muros con antorchas, rejas de hierro, celdas y fosos.
7. **Templo y Ruinas Sagradas:** Mármol agrietado, pilares caídos, mosaicos geométricos y símbolos místicos.

**Directriz de Rediseño (Inspiración Bleaklight Falls):**
- Superar la cuadrícula rígida de 16×16 mediante piezas de tileset grandes (32×32 / 64×64 o bordes orgánicos con máscara de transparencia).
- Iluminación ambiental difusa que tiña el bioma (ej. luz dorada en Silverleaf, azulada-fría en ruinas nevadas, verdosa-sombría en el pantano).

---

## 8. Habilidades y Efectos Especiales (`s/0` a `s/10`)

Total confirmado: **76 frames de efectos visuales**.
- **Tajadas y cortes físicos:** Formas curvas transparentes con borde blanco brillante.
- **Magias elementales:** Fuego (esferas y columnas ascendentes), Hielo (picos cristalinos), Rayo (arcos angulares eléctricos).
- **Tratamiento en Godot:** Mantener los diseños de las formas de impacto como sprites estilizados dibujados, complementados con emisores de partículas 2D para humo, brasas, polvo de impacto y ondas de choque.

---

## 9. Hojas de Contacto de Referencia Generadas

Ubicación en el entorno de desarrollo: `out/contact_sheets/`
1. `contact_hero_and_weapons.png` (1.259 frames)
2. `contact_enemies_part1.png` (481 frames)
3. `contact_enemies_part2.png` (482 frames)
4. `contact_skills_vfx.png` (76 frames)
5. `contact_map_objects.png` (170 frames)
6. `contact_ui_icons.png` (241 frames)

*Todas las hojas quedan a disposición para consulta visual inmediata en Krita o visores de imagen del sistema durante la producción de arte de las Fases 4 y 5.*
