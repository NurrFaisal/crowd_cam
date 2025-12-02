import face_recognition
import numpy as np
from PIL import Image
import io
import pickle
from django.conf import settings
from missing_persons.models import MissingPerson, FaceEncoding

class FaceProcessor:
    @staticmethod
    def extract_face_encoding(image_file):
        try:
            image = face_recognition.load_image_file(image_file)
            face_encodings = face_recognition.face_encodings(image)
            
            if len(face_encodings) == 0:
                return None
            
            return face_encodings[0]
        except Exception as e:
            print(f"Error extracting face encoding: {e}")
            return None
    
    @staticmethod
    def save_face_encoding(missing_person, encoding):
        try:
            encoding_data = pickle.dumps(encoding)
            face_encoding, created = FaceEncoding.objects.get_or_create(
                missing_person=missing_person,
                defaults={'encoding_data': encoding_data}
            )
            if not created:
                face_encoding.encoding_data = encoding_data
                face_encoding.save()
            return face_encoding
        except Exception as e:
            print(f"Error saving face encoding: {e}")
            return None
    
    @staticmethod
    def compare_faces(input_image_file, tolerance=None):
        if tolerance is None:
            tolerance = settings.FACE_RECOGNITION_TOLERANCE
        
        try:
            input_image = face_recognition.load_image_file(input_image_file)
            input_encodings = face_recognition.face_encodings(input_image)
            
            if len(input_encodings) == 0:
                return []
            
            input_encoding = input_encodings[0]
            matches = []
            
            for face_enc in FaceEncoding.objects.select_related('missing_person'):
                if not face_enc.missing_person.is_active:
                    continue
                
                stored_encoding = pickle.loads(face_enc.encoding_data)
                distance = face_recognition.face_distance([stored_encoding], input_encoding)[0]
                
                if distance <= tolerance:
                    confidence = 1 - distance
                    matches.append({
                        'missing_person': face_enc.missing_person,
                        'confidence': confidence,
                        'distance': distance
                    })
            
            matches.sort(key=lambda x: x['confidence'], reverse=True)
            return matches
            
        except Exception as e:
            print(f"Error comparing faces: {e}")
            return []
    
    @staticmethod
    def process_missing_person_photo(missing_person):
        if not missing_person.photo:
            return False
        
        try:
            encoding = FaceProcessor.extract_face_encoding(missing_person.photo.path)
            if encoding is not None:
                FaceProcessor.save_face_encoding(missing_person, encoding)
                return True
            return False
        except Exception as e:
            print(f"Error processing missing person photo: {e}")
            return False