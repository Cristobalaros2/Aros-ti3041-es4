from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from . import api

app_name = "api"

urlpatterns = [
    path("productos/", api.ProductoList.as_view(), name="producto-list"),
    path("productos/<int:pk>/", api.ProductoDetail.as_view(), name="producto-detail"),
    path("token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
]
