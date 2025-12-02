from .views import home
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('', home),
    path('admin/', admin.site.urls),
    path('api/v1/missing-persons/', include('missing_persons.urls')),
    path('api/v1/face-recognition/', include('face_recognition_app.urls')),
    path('api/v1/camera/', include('camera_network.urls')),

    # JWT Authentication endpoints
    path('api/v1/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/v1/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
