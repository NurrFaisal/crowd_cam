from rest_framework import viewsets, status
from rest_framework.decorators import api_view, action
from rest_framework.response import Response
from django.contrib.auth.models import User
from django.db import models
from .models import CameraNode, NetworkAlert
from .serializers import CameraNodeSerializer, NetworkAlertSerializer

class CameraNodeViewSet(viewsets.ModelViewSet):
    serializer_class = CameraNodeSerializer
    
    def get_queryset(self):
        if self.request.user.is_authenticated:
            return CameraNode.objects.filter(user=self.request.user)
        return CameraNode.objects.none()
    
    def perform_create(self, serializer):
        user = self.request.user if self.request.user.is_authenticated else None
        if not user:
            user = User.objects.get_or_create(username='anonymous')[0]
        serializer.save(user=user)
    
    @action(detail=True, methods=['post'])
    def heartbeat(self, request, pk=None):
        camera_node = self.get_object()
        
        latitude = request.data.get('latitude')
        longitude = request.data.get('longitude')
        location_name = request.data.get('location_name', '')
        
        if latitude and longitude:
            camera_node.latitude = latitude
            camera_node.longitude = longitude
            camera_node.location_name = location_name
        
        camera_node.save()
        
        return Response({'status': 'heartbeat received'})
    
    @action(detail=False, methods=['get'])
    def active_nodes(self, request):
        from django.utils import timezone
        from datetime import timedelta
        
        five_minutes_ago = timezone.now() - timedelta(minutes=5)
        active_nodes = CameraNode.objects.filter(
            is_active=True,
            last_seen__gte=five_minutes_ago
        )
        
        serializer = self.get_serializer(active_nodes, many=True)
        return Response(serializer.data)

class NetworkAlertViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = NetworkAlertSerializer
    
    def get_queryset(self):
        from django.utils import timezone
        
        queryset = NetworkAlert.objects.filter(
            is_active=True
        ).filter(
            models.Q(expires_at__isnull=True) | models.Q(expires_at__gt=timezone.now())
        )
        
        if self.request.user.is_authenticated:
            user_nodes = CameraNode.objects.filter(user=self.request.user)
            queryset = queryset.filter(
                models.Q(broadcast_to_all=True) | 
                models.Q(target_nodes__in=user_nodes)
            ).distinct()
        else:
            queryset = queryset.filter(broadcast_to_all=True)
        
        return queryset.order_by('-created_at')

@api_view(['POST'])
def register_device(request):
    device_id = request.data.get('device_id')
    device_name = request.data.get('device_name', 'Unknown Device')
    
    if not device_id:
        return Response(
            {'error': 'device_id is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    user = request.user if request.user.is_authenticated else None
    if not user:
        user = User.objects.get_or_create(username='anonymous')[0]
    
    camera_node, created = CameraNode.objects.get_or_create(
        device_id=device_id,
        defaults={
            'user': user,
            'device_name': device_name,
            'is_active': True
        }
    )
    
    if not created:
        camera_node.device_name = device_name
        camera_node.is_active = True
        camera_node.save()
    
    serializer = CameraNodeSerializer(camera_node)
    return Response(serializer.data, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)