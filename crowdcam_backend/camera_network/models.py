from django.db import models
from django.contrib.auth.models import User
import uuid

class CameraNode(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='camera_nodes')
    device_id = models.CharField(max_length=100, unique=True)
    device_name = models.CharField(max_length=100)
    is_active = models.BooleanField(default=True)
    last_seen = models.DateTimeField(auto_now=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    location_name = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.device_name} ({self.user.username})"
    
    class Meta:
        ordering = ['-last_seen']

class NetworkAlert(models.Model):
    ALERT_TYPES = [
        ('new_missing_person', 'New Missing Person'),
        ('possible_match', 'Possible Match'),
        ('system_update', 'System Update'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    alert_type = models.CharField(max_length=20, choices=ALERT_TYPES)
    title = models.CharField(max_length=200)
    message = models.TextField()
    target_nodes = models.ManyToManyField(CameraNode, blank=True)
    broadcast_to_all = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    
    def __str__(self):
        return f"{self.title} ({self.alert_type})"
    
    class Meta:
        ordering = ['-created_at']