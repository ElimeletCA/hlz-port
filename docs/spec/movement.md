# Especificación de Movimiento, Coordenadas y Colisiones (T3.2)

**Documento:** `docs/spec/movement.md`  
**Clases desofuscadas fuente:** `ee.java`, `dg.java`, `dq.java`, `e.java`, `rpg/b.java`  
**Estado:** Confirmado por ingeniería inversa  

---

## 1. Sistema de Coordenadas Dual (Píxeles vs. Tiles)

Toda entidad móvil (`Actor` / `ee.java`) mantiene simultáneamente su posición precisa en el espacio continuo del mapa y su coordenada discreta en la cuadrícula de casillas:

| Variable | Tipo | Significado técnico | Relación matemática |
|---|---|---|---|
| `h` | `short` | Posición horizontal en **píxeles** globales del mapa. | Posición continua $X$ |
| `i` | `short` | Posición vertical en **píxeles** globales del mapa. | Posición continua $Y$ |
| `s` | `byte` | Columna de casilla (**Tile X**) en el mapa. | $s = h \gg 4 = \lfloor h / 16 \rfloor$ |
| `t` | `byte` | Fila de casilla (**Tile Y**) en el mapa. | $t = i \gg 4 = \lfloor i / 16 \rfloor$ |
| `j` | `boolean` | Desfase sub-tile horizontal activo ($X \pmod{16} \neq 0$). | $j = (h \ \& \ 15) \neq 0$ |
| `k` | `boolean` | Desfase sub-tile vertical activo ($Y \pmod{16} \neq 0$). | $k = (i \ \& \ 15) \neq 0$ |

- **Dimensiones de casilla:** Cada tile mide estrictamente **16 × 16 píxeles**.
- **Dimensiones del mapa en píxeles:**
  $$\text{pixel\_width} = \text{width} \times 16, \quad \text{pixel\_height} = \text{height} \times 16$$

---

## 2. Direcciones Canónicas y Vectores de Desplazamiento

Las direcciones se indexan con valores enteros del 1 al 4 (cardinales) y del 5 al 8 (diagonales), respaldadas por los arreglos constantes `rpg.b.G` ($\Delta X$) y `rpg.b.H` ($\Delta Y$):

```java
// Desplazamiento unitario por dirección (rpg/b.java)
byte[] G = new byte[]{0,  0, 0, -1, 1, -1,  1, -1, 1}; // Delta X
byte[] H = new byte[]{0, -1, 1,  0, 0, -1, -1,  1, 1}; // Delta Y
byte[] M = new byte[]{0,  2, 1,  4, 3};                 // Dirección opuesta
```

| ID | Nombre | Vector $(\Delta X, \Delta Y)$ | Dirección Opuesta `M[id]` |
|:---:|:---:|:---:|:---:|
| **1** | Norte / Arriba (Up) | $(0, -1)$ | 2 (Sur) |
| **2** | Sur / Abajo (Down) | $(0, 1)$ | 1 (Norte) |
| **3** | Oeste / Izquierda (Left) | $(-1, 0)$ | 4 (Este) |
| **4** | Este / Derecha (Right) | $(1, 0)$ | 3 (Oeste) |
| **5** | Noroeste (Up-Left) | $(-1, -1)$ | 8 (Sureste) |
| **6** | Noreste (Up-Right) | $(1, -1)$ | 7 (Suroeste) |
| **7** | Suroeste (Down-Left) | $(-1, 1)$ | 6 (Noreste) |
| **8** | Sureste (Down-Right) | $(1, 1)$ | 5 (Noroeste) |

---

## 3. Velocidades de Desplazamiento

El avance del personaje y de las entidades por cada tick de lógica está regido por la tabla de velocidad `d` de `dq.java`:
```java
private static final byte[] d = new byte[]{1, 2, 3, 3}; // Píxeles por paso según preset
```

- En configuración normal (`c = 2`), el protagonista se desplaza a una velocidad constante de:
  $$V_{\text{normal}} = 3 \text{ píxeles / tick}$$
  A una tasa de 14 Hz:
  $$\text{Velocidad real} = 3 \text{ px/tick} \times 14 \text{ ticks/s} = 42 \text{ píxeles/segundo}$$
- **Modificadores de estado:**
  - Si el personaje sufre ralentización o congelamiento leve (`this.b == true` en `dg.java` línea 1532):
    $$V_{\text{slow}} = \left\lfloor \frac{V \times 4}{5} \right\rfloor = 80\% \text{ de la velocidad base}$$

---

## 4. Reglas de Colisión por Casilla (Bitwise)

Las colisiones de escenario se consultan en la capa de superposición (`overlay_layer` en `e.java` líneas 917–930):

```java
final boolean is_collision(int x, int y) {
    return (overlay_layer[y * width + x] & 192) != 0;
}

final boolean is_solid_wall(int x, int y) {
    return (overlay_layer[y * width + x] & 128) != 0;
}

final boolean is_invisible_barrier(int x, int y) {
    int val = overlay_layer[y * width + x];
    return (val & 192) != 0 && (val & 63) == 0;
}
```

### Tabla de Banderas de Colisión (`uint8`)

| Máscara de bits | Nombre | Comportamiento |
|---|---|---|
| `0x80` (`128`) | Muro sólido / Obstáculo total | Bloquea totalmente el paso de personajes, proyectiles terrestres y enemigos. |
| `0x40` (`64`) | Colisión secundaria / Altura | Elevación o borde con desnivel. |
| `0xC0` (`192`) | Bloqueo estricto | Combinación de colisión absoluta. |
| `0x3F` (`63`) | Índice de tile decorativo | Si es `0` con bloqueo activo, representa una barrera invisible de borde de mapa. |

---

## 5. Adaptación para Mandos Modernos (Gamepad)

1. **Stick Analógico a Intención Digital:**
   - Zona muerta mínima: `0.20`.
   - Se calcula el ángulo $\theta = \text{atan2}(Y, X)$ para determinar la dirección canónica (1..4) o permitir desplazamiento con normalización a $42 \text{ px/s}$.
2. **Punto de Apoyo (Pivote de Colisión):**
   - El punto de colisión del pie del sprite se sitúa en $(X + 8, Y + 14)$ dentro de la celda de $16 \times 16$, permitiendo que la cabeza y torso del personaje solapen decoraciones elevadas sin bloquearse prematuramente.
