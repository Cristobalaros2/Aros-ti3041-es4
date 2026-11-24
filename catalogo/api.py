from rest_framework import generics, permissions

from .models import Producto
from .serializers import ProductoSerializer


class ProductoList(generics.ListCreateAPIView):
    queryset = Producto.objects.all()
    serializer_class = ProductoSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class ProductoDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Producto.objects.all()
    serializer_class = ProductoSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
