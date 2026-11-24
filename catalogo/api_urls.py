from django.urls import path

from . import api

app_name = "api"

urlpatterns = [
    path("productos/", api.ProductoList.as_view(), name="producto-list"),
    path("productos/<int:pk>/", api.ProductoDetail.as_view(), name="producto-detail"),
]
