from rest_framework import serializers
from .models import DetectionResult, CameraUser

class DetectionResultSerializer(serializers.ModelSerializer):
    missing_person_name = serializers.CharField(source='missing_person.name', read_only=True)
    camera_user_name = serializers.CharField(source='camera_user.username', read_only=True)
    
    class Meta:
        model = DetectionResult
        fields = [
            'id', 'missing_person', 'missing_person_name',
            'camera_user', 'camera_user_name', 'confidence_score',
            'image', 'detected_at', 'latitude', 'longitude',
            'location', 'verified', 'false_positive'
        ]
        read_only_fields = ['id', 'detected_at']

class CameraUserSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    
    class Meta:
        model = CameraUser
        fields = [
            'user', 'username', 'is_active_volunteer',
            'total_detections', 'verified_detections',
            'reputation_score', 'location_sharing_enabled'
        ]
        read_only_fields = ['total_detections', 'verified_detections', 'reputation_score']