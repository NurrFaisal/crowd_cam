from django.urls import path
from . import views

urlpatterns = [
    path('detect/', views.detect_faces, name='detect_faces'),
    path('detections/', views.detection_history, name='detection_history'),
    path('detections/<uuid:detection_id>/verify/', views.verify_detection, name='verify_detection'),
]