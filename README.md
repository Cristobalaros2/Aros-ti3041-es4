# aros-ti3041-es4

Evaluación Sumativa 4 (ES4) — Programación Back End (TI3041)  
Catálogo online: Ferretería El Martillo — **API REST con Django REST Framework y autenticación JWT**.

## Requisitos

- Python 3.12
- Django 6.1, djangorestframework, djangorestframework-simplejwt (ver `requirements.txt`)

```bash
pip install -r requirements.txt
python manage.py migrate
python manage.py loaddata productos   # 40 productos de la ferretería
python manage.py runserver
```

Superusuario de prueba: `admin` / `admin123`.

## Endpoints de la API

| Método | Ruta | Auth | Descripción | Códigos |
|--------|------|------|-------------|---------|
| GET | `/api/productos/` | pública | Listado completo | 200 |
| GET | `/api/productos/<id>/` | pública | Detalle | 200, 404 |
| POST | `/api/productos/` | JWT | Crear producto | 201, 400, 401 |
| PUT | `/api/productos/<id>/` | JWT | Actualizar completo | 200, 400, 401, 404 |
| PATCH | `/api/productos/<id>/` | JWT | Actualizar parcial | 200, 400, 401, 404 |
| DELETE | `/api/productos/<id>/` | JWT | Eliminar | 204, 401, 404 |
| POST | `/api/token/` | — | Obtener token (access + refresh) | 200, 400 |
| POST | `/api/token/refresh/` | — | Refrescar access token | 200, 400 |

Lectura pública; escritura protegida con `Authorization: Bearer <access>`.

## Etapas y commits

| Etapa | Entregable | Commit |
|-------|------------|--------|
| 0. DRF | Instalación y configuración de DRF + simplejwt | `etapa-0-drf` |
| 1. Lectura | Serializer y GET listado/detalle | `etapa-1-lectura` |
| 2. Escritura | POST, PUT/PATCH, DELETE con validaciones 400 | `etapa-2-escritura` |
| 3. JWT | Token/refresh y protección de escritura (401 sin token) | `etapa-3-jwt` |
| 4. Pruebas y entrega | Colección curl, `pruebas_api.md`, `uso_ia.md` | `entrega-final` |

## Pruebas

```bash
python manage.py runserver
bash coleccion_pruebas.sh   # 13 pruebas: ver pruebas_api.md
```

## Documentos de la evaluación

- [`pruebas_api.md`](pruebas_api.md) — resultados esperado vs obtenido
- [`uso_ia.md`](uso_ia.md) — registro de consultas a IA y explicación del proceso
- [`coleccion_pruebas.sh`](coleccion_pruebas.sh) — colección de requests curl
