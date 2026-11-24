# Documento de uso de IA — ES4 API REST del catálogo

## Parte 1: Registro de consultas

### Consulta 1 — Preparación del entorno e interpretación de la pauta (Etapa 0)
**Prompt:** "C:\Users\arosc\OneDrive\Escritorio\CUARTO SEMESTRE\PROGRAMACIÓN BACK END\Evaluacion 4 a traves de esta pauta y escala de apreciacion, necesito que hagas todo esto en esta carpeta donde se encuentran los archivos, pagina y todo eso C:\Users\arosc\OneDrive\Escritorio\CUARTO SEMESTRE\PROGRAMACIÓN BACK END\Evaluacion4 VS" (junto con la pauta `Evaluación Sumativa 4` y la escala de apreciacion).

**Resumen de respuesta:** La IA leyó la pauta y la escala, exploró el proyecto de la ES3 (modelo `Producto`, fixture de 40 productos, superusuario `admin`), detectó que faltaban DRF y simplejwt, que `requirements.txt` estaba en UTF-16 y que el README/uso_ia eran de evaluaciones anteriores. Propuso un plan por etapas con los 5 commits de la pauta y preguntó sobre repositorio GitHub, historial git, credenciales y la Parte 2 de `uso_ia.md`.

**Qué usó o modificó antes de integrarla:** Respondí las preguntas (repo nuevo `aros-ti3041-es4`, historial limpio solo ES4, contraseña `admin123`, borrador de la Parte 2 para personalizar). Antes de codificar descarté el cambio suelto de `tema.css`, reinicié el historial git con una rama orfan y apunté el remote al repo nuevo.

### Consulta 2 — Instalación y configuración de DRF (Etapa 0)
**Prompt:** (parte del plan aprobado) "Instalar con pip: djangorestframework + djangorestframework-simplejwt; reescribir requirements.txt (UTF-8) y actualizar Pipfile. settings.py: rest_framework en INSTALLED_APPS + bloque REST_FRAMEWORK con JWTAuthentication."

**Resumen de respuesta:** Instaló `djangorestframework==3.18.3` y `djangorestframework-simplejwt==5.5.1`, reescribió `requirements.txt` en UTF-8, agregó los paquetes al `Pipfile`, configuró `INSTALLED_APPS` y `REST_FRAMEWORK` (JWTAuthentication + SessionAuthentication, permisos AllowAny por defecto, renderers JSON y Browsable API) siguiendo el quickstart oficial de DRF. `manage.py check` sin errores. Commit `etapa-0-drf`.

**Qué usó o modificó antes de integrarla:** Verifiqué con `python manage.py check` y con `import rest_framework` que todo cargara. La configuración se contrastó con https://www.django-rest-framework.org/tutorial/quickstart/ y la de simplejwt con su getting started oficial.

### Consulta 3 — Serializer y endpoints de lectura (Etapa 1)
**Prompt:** (parte del plan) "Etapa 1: serializer del modelo principal. Implemente los endpoints GET /api/productos/ (listado completo) y GET /api/productos/<id>/ (detalle), respondiendo JSON con los códigos correctos (200, 404)."

**Resumen de respuesta:** Creó `catalogo/serializers.py` con `ProductoSerializer` (campos `id, nombre, categoria, precio, stock, imagen`; validaciones de nombre ≥ 3 caracteres, categoría no vacía, precio y stock ≥ 0), `catalogo/api.py` con `ProductoList` y `ProductoDetail` (generic views de DRF), `catalogo/api_urls.py` y el include en `config/urls.py`. Probado: listado 200 con 39 productos, detalle 200, inexistente 404. Commit `etapa-1-lectura`.

**Qué usó o modificó antes de integrarla:** Levanté el servidor y probé los tres casos con requests reales antes de commitear.

### Consulta 4 — Endpoints de escritura (Etapa 2)
**Prompt:** (parte del plan) "Etapa 2: POST (crear), PUT o PATCH (actualizar) y DELETE (eliminar) sobre el recurso. Las validaciones del serializer deben rechazar datos inválidos con código 400."

**Resumen de respuesta:** Extendió las vistas a `ListCreateAPIView` y `RetrieveUpdateDestroyAPIView`. Probado: POST válido 201, POST inválido 400 con mensajes por campo, PATCH 200, PUT 200, DELETE 204. Commit `etapa-2-escritura`.

**Qué usó o modificó antes de integrarla:** En la primera prueba manual el PUT devolvió 400; al investigar vi que era la codificación del body en PowerShell (el `ñ` se mandaba mal), no la API — con UTF-8 correcto respondía 200. Limpié los productos de prueba de la BD antes del commit.

### Consulta 5 — Recomendaciones de seguridad JWT (Etapa 3)
**Prompt:** (parte del plan, exigido por la pauta) "Solicite a la IA recomendaciones de seguridad para su implementación (expiración y refresco de tokens, permisos por método, manejo de errores), valídelas contra la documentación oficial y aplique las que correspondan."

**Resumen de respuesta:** Recomendaciones recibidas y contrastadas con la documentación oficial de simplejwt (https://django-rest-framework-simplejwt.readthedocs.io/en/latest/settings.html):
1. **Vida corta del access token** — `ACCESS_TOKEN_LIFETIME = timedelta(minutes=15)` (los defaults de la librería son más largos para producción).
2. **Refresh de vida media** — `REFRESH_TOKEN_LIFETIME = timedelta(days=1)`.
3. **Rotación de refresh** — `ROTATE_REFRESH_TOKENS = True` para que cada refresh entregue un refresh nuevo.
4. **Prefijo Bearer** — `AUTH_HEADER_TYPES = ('Bearer',)` según el getting started oficial.
5. **Permisos por método** — `IsAuthenticatedOrReadOnly` en las vistas: SAFE_METHODS (GET/HEAD/OPTIONS) públicos, escritura solo autenticada → 401 sin token.
6. **Manejo de errores** — DRF devuelve 401 con `{"detail":"Given token not valid..."}` sin token/inválido, y 400 en el login con credenciales malas; la lectura nunca exige token.

**Qué usó o modificó antes de integrarla:** Apliqué 1–5 en `settings.py` (`SIMPLE_JWT`) y en `catalogo/api.py`. Verifiqué el flujo completo: token con admin 200 → POST con token 201 → POST/PUT/DELETE sin token 401 → refresh 200. Commit `etapa-3-jwt`.

### Consulta 6 — Colección de pruebas con IA (Etapa 4)
**Prompt (el de la pauta):**
> Genera una coleccion de requests curl para probar una API DRF en
> http://localhost:8000/api/productos/ con JWT en /api/token/. Cubre: listado,
> detalle existente y 404, POST valido e invalido, PUT, DELETE, y POST sin
> token (debe dar 401). Incluye el codigo de respuesta esperado en cada caso.

**Resumen de respuesta:** Una colección curl con los casos pedidos y los códigos esperados (200, 404, 201, 400, 401, 204) más la obtención y refresco de token.

**Qué usó o modificó antes de integrarla:** La adapté a este proyecto en `coleccion_pruebas.sh`: rutas `/api/`, login con `admin/admin123`, obtainsión de token y refresh, PATCH además de PUT, y borrado del producto creado para no ensuciar la BD.

**Pruebas que fallaron inicialmente y corrección aplicada (ver detalle en pruebas_api.md):**
- **PUT con token → 400** en la primera ejecución: el JSON con `ñ` pasado por variable de bash en Windows llegaba en Latin-1 (`0xf1`) y Django respondía error de UTF-8. **Corrección:** guardar la respuesta con `curl -o` y reenviar con `-d @archivo` para preservar los bytes. Tras la corrección: 200.
- **POST /api/token/ → 400** en un intento con runner de PowerShell: PowerShell 5.1 comillaba mal el body al invocar `curl.exe`. **Corrección:** ejecutar la colección con Git Bash; respondió 200. No era defecto de la API.

Resultado final de la ejecución: **13 OK, 0 FAIL** (`pruebas_api.md`).

### Consulta 7 — Documentación de entrega (Etapa 4)
**Prompt:** (parte del plan) "Escribir pruebas_api.md con esperado vs obtenido, reescribir README.md para ES4 y uso_ia.md con Parte 1 y Parte 2."

**Resumen de respuesta:** `pruebas_api.md` con tabla de 13 pruebas y el análisis de los fallos iniciales; `README.md` con endpoints, etapas y cómo levantar el proyecto; este `uso_ia.md`.

**Qué usó o modificó antes de integrarla:** Revisé que cada consulta de la Parte 1 correspondiera a lo realmente pedido en esta sesión y que los resultados de pruebas coincidieran con la última ejecución. La Parte 2 la dejo como borrador para que la reescriba con mis propias palabras, como exige la pauta.

---

## Parte 2: Explicación del proceso

> **BORRADOR — reescribir con tus palabras antes de entregar.**  
> La pauta no acepta textos redactados por IA en esta parte.

En esta evaluación usé la IA como copiloto para montar la API REST sobre el proyecto de la ferretería que ya tenía de la ES3. Al principio le pedí que leyera la pauta y la escala y me propusiera un plan por etapas; eso me sirvió para ordenar el trabajo y no saltarme nada de los commits. Lo que más me sirvió tal cual fue la configuración de DRF y simplejwt: la copió de la documentación oficial y solo tuve que verificar con `manage.py check` que no rompiera nada.

Las recomendaciones de seguridad del token las pedí como exige la pauta y luego las contrasté con la web de simplejwt antes de aplicarlas; ahí aprendí por qué el access token tiene que vivir poco (15 minutos) y el refresh más (un día), y por qué conviene rotar el refresh. Lo que tuve que corregir fue en las pruebas: el PUT me falló con un error raro de UTF-8 y al principio pensé que estaba mal la API, pero el problema era que el `ñ` del producto se perdía al pasar el JSON por bash en Windows; la solución fue guardar la respuesta en un archivo y reenviarla tal cual. También un intento de correr todo desde PowerShell se rompía por el comillado de los JSON y cambié a Git Bash.

Lo que aprendí es que probar la API con una colección de verdad (y anotar esperado vs obtenido) encuentra huecos que mirando el código no se ven, y que cuando algo falla conviene primero saber quién falla: el servidor o el cliente. Parte de esto lo voy a reescribir con mis propias palabras antes de entregar, como pide la pauta.
