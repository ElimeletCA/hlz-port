# Especificación de formato binario: .mpm (Modular PNG/Multi-Picture Media)

Documento técnico deducido a partir de la desofuscación de `ba.java` y comprobado con reconstrucción exitosa de imágenes vía Python/Pillow.

---

## 1. Propósito

El formato `.mpm` es un contenedor propietario utilizado en Heroes Lore: Zero para optimizar el almacenamiento de spritesheets, animaciones y elementos gráficos compartiendo paletas indexadas y dividiendo los chunks estándar de PNG.

---

## 2. Estructura binaria de alto nivel

Un archivo `.mpm` consta de una cabecera de bloques empaquetados por longitud (Big-Endian uint16):

```
+-------------------------------------------------------------+
| Bloque C: Longitud (2B) + Metadatos, Flags y Chunks PNG     |
| (incluye chunks PLTE y tRNS compartidos)                    |
+-------------------------------------------------------------+
| Sub-bloque 0: Longitud (2B) + Chunks PNG (IHDR, IDAT)       |
+-------------------------------------------------------------+
| Sub-bloque 1: Longitud (2B) + Chunks PNG (IHDR, IDAT)...    |
+-------------------------------------------------------------+
```

### Cabecera del Bloque C (`this.c` en `ba.java`)

| Desplazamiento | Tipo | Campo | Descripción |
|----------------|------|-------|-------------|
| `0x00` | `uint16_be` | `len_block_c` | Longitud en bytes de los metadatos y chunks compartidos. |
| `0x02` | `uint32_be` | `flags` | Banderas de renderizado: bit 27 (`is_a`), bit 26 (`is_b` = requiere inversión de bits de scanline). |
| `0x06` | `uint32_be` | `sub_count` | Número total de sub-imágenes o frames contenidos. |
| `0x0A` | `bytes` | `chunks_c` | Chunks PNG compartidos (`PLTE` con paleta RGB y opcionalmente `tRNS` para transparencia). |

---

## 3. Reconstrucción de un archivo PNG estándar

Para exportar un PNG estándar a partir de un `.mpm`:

1. Escribir la firma mágica PNG: `\x89PNG\r\n\x1a\n` (8 bytes).
2. Extraer y escribir el chunk `IHDR` del sub-bloque correspondiente.
3. Extraer y escribir el chunk `PLTE` (paleta compartida) del Bloque C.
4. Si existe, extraer y escribir el chunk `tRNS` (transparencia) del Bloque C.
5. Extraer y escribir el chunk `IDAT` del sub-bloque correspondiente.
6. Escribir el chunk terminador `IEND`: `\x00\x00\x00\x00IEND\xaeB\x60\x82`.

---

## 4. Verificación técnica

Probado con éxito sobre `en/0/01.mpm`. El archivo reconstruido abre de forma nativa en Pillow/PIL con modo indexado `P` y dimensiones exactas `(10, 19)`.
