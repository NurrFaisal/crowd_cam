from rest_framework import serializers
from .models import CameraNode, NetworkAlert

class CameraNodeSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    
    class Meta:
        model = CameraNode
        fields = [
            'id', 'user', 'username', 'device_id', 'device_name',
            'is_active', 'last_seen', 'latitude', 'longitude',
            'location_name', 'created_at'
        ]
        read_only_fields = ['id', 'user', 'last_seen', 'created_at']

class NetworkAlertSerializer(serializers.ModelSerializer):
    target_node_count = serializers.IntegerField(source='target_nodes.count', read_only=True)
    
    class Meta:
        model = NetworkAlert
        fields = [
            'id', 'alert_type', 'title', 'message', 'target_node_count',
            'broadcast_to_all', 'created_at', 'expires_at', 'is_active'
        ]
        read_only_fields = ['id', 'created_at']