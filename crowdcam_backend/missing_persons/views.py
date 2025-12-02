from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django.contrib.auth.models import User
from .models import MissingPerson, FaceEncoding
from .serializers import MissingPersonSerializer
from face_recognition_app.face_processor import FaceProcessor

class MissingPersonViewSet(viewsets.ModelViewSet):
    queryset = MissingPerson.objects.filter(is_active=True)
    serializer_class = MissingPersonSerializer
    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):
        user = self.request.user if self.request.user.is_authenticated else None
        if not user:
            user = User.objects.get_or_create(username='anonymous')[0]
        
        missing_person = serializer.save(reported_by=user)
        
        if missing_person.photo:
            success = FaceProcessor.process_missing_person_photo(missing_person)
            if not success:
                return Response(
                    {'error': 'Failed to process face from photo. Please ensure the photo contains a clear face.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['post'])
    def deactivate(self, request, pk=None):
        missing_person = self.get_object()
        missing_person.is_active = False
        missing_person.save()
        return Response({'status': 'Missing person deactivated'})

    @action(detail=True, methods=['post'])
    def reactivate(self, request, pk=None):
        missing_person = self.get_object()
        missing_person.is_active = True
        missing_person.save()
        return Response({'status': 'Missing person reactivated'})

    @action(detail=False, methods=['get'])
    def active(self, request):
        active_persons = MissingPerson.objects.filter(is_active=True)
        serializer = self.get_serializer(active_persons, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def recent(self, request):
        recent_persons = MissingPerson.objects.filter(is_active=True).order_by('-reported_date')[:10]
        serializer = self.get_serializer(recent_persons, many=True)
        return Response(serializer.data)