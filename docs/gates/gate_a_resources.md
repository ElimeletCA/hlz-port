# Puerta de Aprobación — Recursos Decodificados Correctamente (Gate A)

Documento de control para asegurar que ningún recurso se integre en masa sin haber sido interpretado, extraído y verificado fuera del motor.

**Estado actual:** `APPROVED`

**Estados válidos:** `PENDING` | `REJECTED` | `APPROVED`

---

## 1. Criterios de Aceptación
1. 100% de los archivos del JAR original inventariados y clasificados por formato.
2. Parsers implementados y verificados para `.mpm`, `.m`, `mmi/`, `.tdf`, paletas y audio.
3. Extracción automatizada sin excepciones a formatos estándar (PNG, JSON, WAV, MIDI).
4. Verificación visual mediante hojas de contacto y renderizados de mapas completos.

## 2. Evidencias Verificadas
- `docs/inventory.csv`: 1,112 archivos inventariados con hash criptográfico SHA-256.
- `reverse/decompiled/`: 144 clases Java decompiladas con Vineflower.
- `docs/formats/`: Especificación completa de `.mpm`, `.m`, `.tdf` y `mmi`.
- `tools/verify_fase2.py`: Ejecución limpia al 100%.
- `out/maps/`: 141 mapas exportados a JSON y renderizados en `out/renders/`.
- `out/sprites/`: 3,199 sprites y frames individuales con canal alfa verificados.

## 3. Dictamen
- **Aprobado el 2026-10-14.** Los extractores y decodificadores de recursos originales son fiables y reproducibles.
