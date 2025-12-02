from django.db import models
from django.contrib.auth.models import User
from missing_persons.models import MissingPerson
import uuid

class DetectionResult(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    missing_person = models.ForeignKey(MissingPerson, on_delete=models.CASCADE, related_name='detections')
    camera_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='detections')
    confidence_score = models.FloatField()
    image = models.ImageField(upload_to='detections/')
    detected_at = models.DateTimeField(auto_now_add=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    location = models.CharField(max_length=300, blank=True)
    verified = models.BooleanField(default=False)
    false_positive = models.BooleanField(default=False)
    
    def __str__(self):
        return f"Detection of {self.missing_person.name} by {self.camera_user.username}"
    
    class Meta:
        ordering = ['-detected_at']

class CameraUser(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    is_active_volunteer = models.BooleanField(default=True)
    total_detections = models.IntegerField(default=0)
    verified_detections = models.IntegerField(default=0)
    reputation_score = models.FloatField(default=100.0)
    location_sharing_enabled = models.BooleanField(default=True)
    
    def __str__(self):
        return f"Camera User: {self.user.username}"