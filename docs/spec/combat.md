# Especificación de Combate: Fórmulas, Daño y Habilidades (T3.3)

**Documento:** `docs/spec/combat.md`  
**Clases desofuscadas fuente:** `dg.java`, `ec.java`, `bx.java`, `t/s0.tdf` a `t/s5.tdf`, `rpg/f.java`  
**Estado:** Confirmado por ingeniería inversa  

---

## 1. Atributos Principales de Personaje y Enemigos

Cada combatiente (jugador o monstruo) posee los siguientes atributos numéricos:

| Atributo | Símbolo | Tipo | Descripción |
|---|---|---|---|
| **Puntos de Vida** | $\text{HP}_{\text{cur}} / \text{HP}_{\text{max}}$ | `int32` / `uint16` | Salud actual y máxima. Si $\text{HP}_{\text{cur}} \le 0$, se activa el estado de muerte. |
| **Puntos de Maná** | $\text{MP}_{\text{cur}} / \text{MP}_{\text{max}}$ | `int32` / `uint16` | Energía mística consumida por habilidades de clase. |
| **Poder de Ataque** | $\text{ATK}$ | `uint16` | Daño base infligido por arma y fuerza. |
| **Defensa Física** | $\text{DEF}$ | `uint16` | Mitigación de daño físico por armadura y escudo. |
| **Ataque / Defensa Mágica** | $\text{MATK} / \text{MDEF}$ | `uint16` | Escala de hechizos y resistencia elemental. |
| **Probabilidad Crítica** | $\text{CRIT}$ | `uint8` (%) | Porcentaje de infligir impacto crítico con daño aumentado. |
| **Tasa de Evasión** | $\text{EVA}$ | `uint8` (%) | Probabilidad de esquivar totalmente un golpe entrante. |

---

## 2. Fórmulas Matemáticas de Combate

### 2.1 Cálculo de Daño Físico Base
El daño neto antes de mitigaciones especiales se calcula como:

$$\text{Daño}_{\text{base}} = \max\left(1, \; \text{ATK}_{\text{atacante}} - \text{DEF}_{\text{objetivo}} + \text{Varianza}\right)$$

Donde la varianza introduce una fluctuación pseudo-aleatoria de $\pm 5\%$:
$$\text{Varianza} = \text{random}\left(-\left\lfloor\frac{\text{ATK}}{20}\right\rfloor, \; \left\lfloor\frac{\text{ATK}}{20}\right\rfloor\right)$$

### 2.2 Verificación de Golpe Crítico
Deducido de `dg.java` (método `h()`, línea 2165):

$$\text{Probabilidad\_Crit} = \max\left(10, \; 60 - \text{DEF}_{\text{objetivo}}\right)$$

$$\text{Tirada} = \text{random}(0, 99)$$
Si $\text{Tirada} < \text{Probabilidad\_Crit}$, el impacto es crítico:
$$\text{Daño}_{\text{crítico}} = \left\lfloor \text{Daño}_{\text{base}} \times 1.5 \right\rfloor$$

### 2.3 Verificación de Evasión (Miss)
Deducido de `dg.java` (método `g()`, línea 2172):

$$\text{Tirada\_Evasión} = \text{random}(1, 99)$$
Si $\text{Tirada\_Evasión} > 100 - \text{EVA}_{\text{objetivo}}$, el ataque es esquivado completamente:
$$\text{Daño} = 0 \quad (\text{Texto en pantalla: "FALLO" / "MISS"})$$

### 2.4 Habilidades Pasivas de Absorción y Vampirismo
Deducido de `dg.java` (método `p()`, líneas 2190–2220):
- **Robo de Vida (Life Leech):**
  $$\text{HP}_{\text{recuperado}} = \left\lfloor \frac{\text{Daño} \times 10}{100} \right\rfloor \quad (10\% \text{ del daño real causante})$$
- **Absorción de Maná (Mana Leech):**
  $$\text{MP}_{\text{recuperado}} = \left\lfloor \frac{\text{Daño} \times 5}{100} \right\rfloor \quad (5\% \text{ del daño real causante})$$

---

## 3. Clases y Habilidades Principales

Extraídas de las tablas de texto `t/s0.tdf` a `t/s5.tdf`:

| Clase | Habilidad Característica | Coste MP | Efecto Mecánico |
|---|---|---|---|
| **Guerrero** (`s0`) | *Golpe Brutal* | 12 MP | Tajo pesado frontal con $150\%$ de daño y probabilidad de aturdimiento (stun 1.5s). |
| **Caballero** (`s2`) | *Barcaza de Escudo* | 10 MP | Carga frontal con escudo que empuja al enemigo 2 casillas y absorbe daño. |
| **Asesino** (`s1`) | *Ataque Sorpresa* | 15 MP | Teletransporte / tajo veloz a la espalda del enemigo con crítico garantizado. |
| **Pistolero** (`s3`) | *Disparo Cercano* | 14 MP | Disparo a quemarropa que genera retroceso y daño perforante. |
| **Gunblader** (`s4`) | *Cannon Blast* | 22 MP | Disparo de cañón de energía frontal en línea recta con daño mágico explosivo. |
| **Elemental** (`s5`) | *Alianza Elemental* | 25 MP | Convocación de aura elemental rotatoria que daña periódicamente a enemigos cercanos. |

---

## 4. Estados Alterados

| Estado | Duración (ticks) | Efecto sobre el objetivo |
|---|---|---|
| **Aturdido (Stun)** | 21 ticks (~1.5s) | Movimiento y ataque completamente deshabilitados. |
| **Ralentizado (Slow)** | 42 ticks (~3.0s) | Velocidad de paso reducida al $80\%$ ($V \times 4 / 5$). |
| **Envenenado (Poison)** | 70 ticks (~5.0s) | Pérdida de $3\%$ de HP máximo cada 14 ticks (1 segundo). |
| **Defensa Elevada (Iron Skin)** | 84 ticks (~6.0s) | Aumento de $+30\%$ de DEF física. |
