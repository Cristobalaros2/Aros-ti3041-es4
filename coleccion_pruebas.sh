#!/usr/bin/env bash
# Colección de pruebas de la API REST del catálogo (ES4)
# Generada con IA (OpenCode) — ver uso_ia.md Parte 1, consulta de la colección de pruebas.
# Requiere: servidor levantado en http://127.0.0.1:8000 y usuario admin/admin123.
# Uso: bash coleccion_pruebas.sh

BASE="http://127.0.0.1:8000/api"
ADMIN_USER="admin"
ADMIN_PASS="admin123"

pass=0
fail=0

check() {
  local nombre="$1" esperado="$2" obtenido="$3"
  if [ "$esperado" = "$obtenido" ]; then
    echo "OK   | $nombre | esperado=$esperado obtenido=$obtenido"
    pass=$((pass + 1))
  else
    echo "FAIL | $nombre | esperado=$esperado obtenido=$obtenido"
    fail=$((fail + 1))
  fi
}

echo "=== Colección de pruebas API — Ferretería El Martillo (ES4) ==="

# 1. Listado de productos (lectura pública)
code=$(curl.exe -s -o /dev/null -w "%{http_code}" "$BASE/productos/")
check "GET listado /api/productos/" 200 "$code"

# 2. Detalle de producto existente (pk=1)
code=$(curl.exe -s -o /dev/null -w "%{http_code}" "$BASE/productos/1/")
check "GET detalle existente /api/productos/1/" 200 "$code"

# 3. Detalle de producto inexistente
code=$(curl.exe -s -o /dev/null -w "%{http_code}" "$BASE/productos/9999/")
check "GET detalle inexistente /api/productos/9999/" 404 "$code"

# 4. Creación válida (sin token aún: debe fallar con 401 en etapa 3+)
#    Se prueba primero sin token y luego con token.
code=$(curl.exe -s -o /dev/null -w "%{http_code}" -X POST "$BASE/productos/" \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Producto sin token","categoria":"Test","precio":1000,"stock":1}')
check "POST sin token (debe 401)" 401 "$code"

# 5. Obtener token JWT con superusuario
token_json=$(curl.exe -s -X POST "$BASE/token/" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$ADMIN_USER\",\"password\":\"$ADMIN_PASS\"}")
code=$(curl.exe -s -o /dev/null -w "%{http_code}" -X POST "$BASE/token/" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$ADMIN_USER\",\"password\":\"$ADMIN_PASS\"}")
check "POST /api/token/ (obtener token)" 200 "$code"

ACCESS=$(echo "$token_json" | python -c "import sys,json; print(json.load(sys.stdin)['access'])" 2>/dev/null)
REFRESH=$(echo "$token_json" | python -c "import sys,json; print(json.load(sys.stdin)['refresh'])" 2>/dev/null)

if [ -z "$ACCESS" ]; then
  echo "ABORT: no se pudo obtener el token JWT"
  exit 1
fi

# 6. Creación válida con token
code=$(curl.exe -s -o /dev/null -w "%{http_code}" -X POST "$BASE/productos/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS" \
  -d '{"nombre":"Taladro de percusion 650W","categoria":"Herramientas electricas","precio":34990,"stock":8}')
check "POST válido con token (crea registro)" 201 "$code"

# 7. Creación inválida con token (precio negativo, nombre corto, categoría vacía)
code=$(curl.exe -s -o /dev/null -w "%{http_code}" -X POST "$BASE/productos/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS" \
  -d '{"nombre":"X","categoria":"","precio":-5,"stock":-1}')
check "POST inválido con token (validaciones)" 400 "$code"

# 8. Actualización parcial (PATCH) con token — precio de pk=1
code=$(curl.exe -s -o /dev/null -w "%{http_code}" -X PATCH "$BASE/productos/1/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS" \
  -d '{"precio":15990}')
check "PATCH /api/productos/1/ con token" 200 "$code"

# 9. Actualización completa (PUT) con token
#    Nota: se guarda la respuesta en un archivo para preservar los bytes UTF-8
#    (ñ): pasar el JSON por variable de bash en Windows lo codificaba en Latin-1
#    y la API respondía 400. Ver pruebas_api.md, prueba 9.
curl.exe -s "$BASE/productos/1/" -o _tmp_p1.json
code=$(curl.exe -s -o /dev/null -w "%{http_code}" -X PUT "$BASE/productos/1/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS" \
  -d @_tmp_p1.json)
rm -f _tmp_p1.json
check "PUT /api/productos/1/ con token" 200 "$code"

# 10. PUT sin token (debe 401)
curl.exe -s "$BASE/productos/1/" -o _tmp_p1.json
code=$(curl.exe -s -o /dev/null -w "%{http_code}" -X PUT "$BASE/productos/1/" \
  -H "Content-Type: application/json" \
  -d @_tmp_p1.json)
rm -f _tmp_p1.json
check "PUT sin token (debe 401)" 401 "$code"

# 11. Refresco de token
code=$(curl.exe -s -o /dev/null -w "%{http_code}" -X POST "$BASE/token/refresh/" \
  -H "Content-Type: application/json" \
  -d "{\"refresh\":\"$REFRESH\"}")
check "POST /api/token/refresh/" 200 "$code"

# 12. Eliminar el producto creado en la prueba 6 (buscar por nombre)
CREADO_ID=$(curl.exe -s "$BASE/productos/" | python -c "
import sys, json
productos = json.load(sys.stdin)
for p in productos:
    if p['nombre'] == 'Taladro de percusion 650W':
        print(p['id'])
        break
")
if [ -n "$CREADO_ID" ]; then
  code=$(curl.exe -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE/productos/$CREADO_ID/" \
    -H "Authorization: Bearer $ACCESS")
  check "DELETE /api/productos/$CREADO_ID/ con token" 204 "$code"
else
  echo "FAIL | DELETE | no se encontró el producto creado en la prueba 6"
  fail=$((fail + 1))
fi

# 13. DELETE sin token (debe 401)
code=$(curl.exe -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE/productos/1/" )
check "DELETE sin token (debe 401)" 401 "$code"

echo ""
echo "=== Resumen: $pass OK, $fail FAIL ==="
[ "$fail" -eq 0 ]
