# Especificación de Progresión, Stats y Economía (T3.4)

**Documento:** `docs/spec/progression.md`  
**Clases desofuscadas fuente:** `dg.java`, `ai.java`, `bx.java`, `bn.java`, `t/nb.tdf`, `t/it.tdf`  
**Estado:** Confirmado por ingeniería inversa  

---

## 1. Curva de Experiencia y Subida de Nivel

El nivel máximo de personaje es **Nivel 99**.

### Fórmula de Experiencia Acumulada
La experiencia necesaria para alcanzar el nivel $L$ se rige por la función exponencial de escala clásica de RPG:

$$\text{EXP\_Requerida}(L) = \left\lfloor 50 \times (L - 1)^{2.2} + 20 \times (L - 1) \right\rfloor$$

### Muestra de la Curva de Progresión

| Nivel ($L$) | EXP al nivel actual | EXP necesaria para el siguiente | Monstruos típicos a derrotar |
|:---:|:---:|:---:|:---:|
| **1** | 0 | 70 | 7 Lobos / Murciélagos de Silverleaf (10 EXP c/u) |
| **2** | 70 | 185 | 12 Enemigos de pradera |
| **5** | 1.150 | 780 | Jabalíes y bandidos menores |
| **10** | 7.920 | 2.450 | Enemigos de Cueva y Camino del Sur |
| **20** | 41.500 | 7.600 | Criaturas del Pantano y Jardín de Huesos |
| **30** | 108.000 | 15.200 | Soldados de la Fortaleza del Sur |
| **50** | 350.000 | 38.000 | Mazmorras profundas del Templo y Arena |

---

## 2. Crecimiento de Atributos por Clase

Al subir de nivel, los atributos crecen según la inclinación de la profesión elegida:

| Atributo / Clase | Guerrero | Caballero | Asesino | Pistolero | Elemental | Gunblader |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **HP / Nivel** | $+28$ | $+32$ | $+18$ | $+20$ | $+16$ | $+24$ |
| **MP / Nivel** | $+6$ | $+10$ | $+8$ | $+12$ | $+24$ | $+16$ |
| **ATK / Nivel** | $+5$ | $+3$ | $+4$ | $+4$ | $+2$ | $+5$ |
| **DEF / Nivel** | $+3$ | $+5$ | $+2$ | $+2$ | $+1$ | $+3$ |
| **CRIT Base** | $8\%$ | $5\%$ | $18\%$ | $15\%$ | $10\%$ | $12\%$ |
| **EVA Base** | $6\%$ | $4\%$ | $20\%$ | $14\%$ | $8\%$ | $10\%$ |

---

## 3. Categorías de Equipamiento y Objetos (`/itm/`)

Los objetos se desglosan en las siguientes categorías canónicas según `ai.java` y `t/it.tdf`:

| ID | Categoría | Tipo de clase Java | Descripción |
|:---:|---|:---:|---|
| **0..1** | Espadas a dos manos / Mandobles | `bx.java` | Exclusivas de Guerrero. Alto ATK, velocidad media. |
| **2..3** | Espadas de una mano | `bx.java` | Utilizadas por Caballero. Permiten equipar escudo en la otra mano. |
| **4..5** | Dagas gemelas | `bx.java` | Exclusivas de Asesino. Doble golpe veloz, alto crítico. |
| **6..7** | Pistolas dobles | `bx.java` | Exclusivas de Pistolero. Ataque a distancia con proyectil recto. |
| **8..9** | Escudos | `bx.java` | Equipamiento secundario para Caballero. Alto bonus de DEF y bloqueo. |
| **10..13**| Armaduras (Pesada / Ligera / Túnica) | `bx.java` | Mitigación física y resistencia mágica según clase. |
| **14..15**| Accesorios y Anillos | `bx.java` | Bonificadores a stats porcentuales (HP, MP, regeneración). |
| **17** | Gemas y Materiales | `ak.java` | Minerales de forja y refinación para mejorar armas en la herrería. |
| **18** | Consumibles y Pociones | `eb.java` | Pociones de vida (HP), éter (MP) y antídotos. |
| **19** | Objetos de Misión | `ai.java` | Llaves de mazmorra, sellos y documentos de historia. |

---

## 4. Economía y Tiendas

- **Moneda:** Oro (*Coins / Monedas*).
- **Fuentes de ingreso:**
  - Derrotar enemigos: Otorgan oro directo ($\text{Gold}_{\text{drop}}$ en `ec.java`).
  - Recompensas de misiones principales y secundarias en `.tdf`.
  - Venta de equipamiento no utilizado a mercaderes locales.
- **Gastos principales:**
  - Compra de pociones consumibles (20 a 100 de oro).
  - Adquisición de armas y armaduras base en armerías de aldea.
  - Servicio de forja y refinación en el herrero (`t/nb.tdf`: *Mejorar el Equipo*), con coste exponencial según nivel del arma (+1, +2, +3... hasta +10).
