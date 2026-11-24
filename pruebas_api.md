# Pruebas de la API REST — Ferretería El Martillo (ES4)

Colección de requests generada con IA (OpenCode) y ejecutada contra el servidor local
(`python manage.py runserver`, `http://127.0.0.1:8000`).  
Colección completa en [`coleccion_pruebas.sh`](coleccion_pruebas.sh).

**Credenciales de prueba:** `admin` / `admin123` (superusuario).

## Prompt utilizado para generar la colección

> Genera una coleccion de requests curl para probar una API DRF en
> http://localhost:8000/api/productos/ con JWT en /api/token/. Cubre: listado,
> detalle existente y 404, POST valido e invalido, PUT, DELETE, y POST sin
> token (debe dar 401). Incluye el codigo de respuesta esperado en cada caso.

La IA devolvió una colección curl que fue adaptada a este proyecto (rutas
`/api/`, superusuario propio y limpieza de registros de prueba) y quedó en
`coleccion_pruebas.sh`.

## Resultados de la ejecución

| # | Prueba | Método y ruta | Esperado | Obtenido | Resultado |
|---|--------|---------------|----------|----------|-----------|
| 1 | Listado (lectura pública) | `GET /api/productos/` | 200 | 200 | OK |
| 2 | Detalle existente | `GET /api/productos/1/` | 200 | 200 | OK |
| 3 | Detalle inexistente | `GET /api/productos/9999/` | 404 | 404 | OK |
| 4 | Escritura sin token | `POST /api/productos/` | 401 | 401 | OK |
| 5 | Obtener token JWT | `POST /api/token/` | 200 | 200 | OK |
| 6 | Creación válida con token | `POST /api/productos/` | 201 | 201 | OK |
| 7 | Creación inválida con token | `POST /api/productos/` | 400 | 400 | OK |
| 8 | Actualización parcial | `PATCH /api/productos/1/` | 200 | 200 | OK |
| 9 | Actualización completa | `PUT /api/productos/1/` | 200 | 200 | OK* |
| 10 | PUT sin token | `PUT /api/productos/1/` | 401 | 401 | OK |
| 11 | Refresco de token | `POST /api/token/refresh/` | 200 | 200 | OK |
| 12 | Eliminación con token | `DELETE /api/productos/<id>/` | 204 | 204 | OK |
| 13 | DELETE sin token | `DELETE /api/productos/1/` | 401 | 401 | OK |

**Resumen final: 13 OK, 0 FAIL.**

### Detalle de los casos con fallo inicial y corrección aplicada

**Prueba 9 — PUT con token (falló en la primera ejecución):**

- **Esperado:** 200  
- **Obtenido (1.ª ejecución):** 400  
  `{"detail":"JSON parse error - 'utf-8' codec can't decode byte 0xf1 in position 31: invalid continuation byte"}`
- **Análisis:** la prueba tomaba el JSON del producto (`"Martillo de uñas…"`) y lo
  pasaba por una variable de bash en Windows; el `ñ` llegaba codificado en
  Latin-1 (byte `0xf1`) en vez de UTF-8 (`c3 b1`), y Django rechazaba el body
  con 400. **La API estaba correcta** (JSON debe viajar en UTF-8, RFC 8259);
  el problema era de la prueba cliente.
- **Corrección aplicada:** guardar la respuesta con `curl -o _tmp_p1.json`
  (bytes en crudo) y reenviarla con `-d @_tmp_p1.json`.  
- **Resultado tras la corrección:** 200 (y la prueba 10 con el mismo archivo
  responde 401 como corresponde).

**Prueba 5 en un intento intermedio (falso positivo de ejecución):**

- Al correr la colección desde un runner en PowerShell, `POST /api/token/`
  devolvió 400 porque PowerShell 5.1 comillaba mal el body JSON al invocar
  `curl.exe`. La colección definitiva se ejecuta con bash/Git Bash y responde
  200. No fue un defecto de la API.

## Cómo reproducir

```bash
python manage.py runserver
# en otra terminal (Git Bash en Windows):
bash coleccion_pruebas.sh
```

Salida esperada: `=== Resumen: 13 OK, 0 FAIL ===`.
