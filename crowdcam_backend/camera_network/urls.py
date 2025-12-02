from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CameraNodeViewSet, NetworkAlertViewSet, register_device

router = DefaultRouter()
router.register(r'nodes', CameraNodeViewSet, basename='camera-nodes')
router.register(r'alerts', NetworkAlertViewSet, basename='network-alerts')

urlpatterns = [
    path('register/', register_device, name='register_device'),
    path('', include(router.urls)),
]