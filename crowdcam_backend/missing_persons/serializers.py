from rest_framework import serializers
from .models import MissingPerson, FaceEncoding

class MissingPersonSerializer(serializers.ModelSerializer):
    photo_url = serializers.SerializerMethodField()
    reported_by_name = serializers.CharField(source='reported_by.username', read_only=True)
    
    class Meta:
        model = MissingPerson
        fields = [
            'id', 'name', 'age', 'description', 'photo', 'photo_url',
            'last_seen_date', 'last_seen_location', 'contact_info',
            'is_active', 'reported_date', 'reported_by', 'reported_by_name'
        ]
        read_only_fields = ['id', 'reported_date', 'reported_by']
    
    def get_photo_url(self, obj):
        if obj.photo:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.photo.url)
            return obj.photo.url
        return ''

class FaceEncodingSerializer(serializers.ModelSerializer):
    missing_person_name = serializers.CharField(source='missing_person.name', read_only=True)
    
    class Meta:
        model = FaceEncoding
        fields = ['missing_person', 'missing_person_name', 'created_at']
        read_only_fields = ['created_at']