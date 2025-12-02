from django.db import models
from django.contrib.auth.models import User
import uuid

class MissingPerson(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=200)
    age = models.IntegerField()
    description = models.TextField()
    photo = models.ImageField(upload_to='missing_persons/')
    last_seen_date = models.DateTimeField()
    last_seen_location = models.CharField(max_length=300)
    contact_info = models.CharField(max_length=300)
    is_active = models.BooleanField(default=True)
    reported_date = models.DateTimeField(auto_now_add=True)
    reported_by = models.ForeignKey(User, on_delete=models.CASCADE)
    
    def __str__(self):
        return f"{self.name} - {self.age} years old"
    
    class Meta:
        ordering = ['-reported_date']

class FaceEncoding(models.Model):
    missing_person = models.OneToOneField(MissingPerson, on_delete=models.CASCADE, related_name='face_encoding')
    encoding_data = models.BinaryField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Face encoding for {self.missing_person.name}"