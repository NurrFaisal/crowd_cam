from rest_framework import status
from rest_framework.decorators import api_view, parser_classes
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django.conf import settings
from django.core.files.storage import default_storage
from .models import DetectionResult, CameraUser
from .face_processor import FaceProcessor
from .serializers import DetectionResultSerializer
import tempfile
import os

@api_view(['POST'])
@parser_classes([MultiPartParser, FormParser])
def detect_faces(request):
    if 'image' not in request.FILES:
        return Response(
            {'error': 'No image provided'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    image_file = request.FILES['image']
    latitude = request.data.get('latitude', 0.0)
    longitude = request.data.get('longitude', 0.0)
    location = request.data.get('location', '')
    
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as temp_file:
            for chunk in image_file.chunks():
                temp_file.write(chunk)
            temp_file_path = temp_file.name
        
        matches = FaceProcessor.compare_faces(temp_file_path)
        
        detections = []
        for match in matches:
            if match['confidence'] >= settings.MIN_FACE_CONFIDENCE:
                detection = DetectionResult.objects.create(
                    missing_person=match['missing_person'],
                    camera_user=request.user if request.user.is_authenticated else None,
                    confidence_score=match['confidence'],
                    image=image_file,
                    latitude=float(latitude),
                    longitude=float(longitude),
                    location=location
                )
                detections.append(detection)
        
        os.unlink(temp_file_path)
        
        serializer = DetectionResultSerializer(detections, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response(
            {'error': f'Face detection failed: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['GET'])
def detection_history(request):
    try:
        if request.user.is_authenticated:
            detections = DetectionResult.objects.filter(camera_user=request.user)
        else:
            detections = DetectionResult.objects.all()[:50]
        
        detections = detections.order_by('-detected_at')
        
        serializer = DetectionResultSerializer(detections, many=True)
        return Response({
            'results': serializer.data,
            'count': detections.count()
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response(
            {'error': f'Failed to fetch detection history: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['POST'])
def verify_detection(request, detection_id):
    try:
        detection = DetectionResult.objects.get(id=detection_id)
        detection.verified = True
        detection.save()
        
        serializer = DetectionResultSerializer(detection)
        return Response(serializer.data, status=status.HTTP_200_OK)
        
    except DetectionResult.DoesNotExist:
        return Response(
            {'error': 'Detection not found'}, 
            status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        return Response(
            {'error': f'Failed to verify detection: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )