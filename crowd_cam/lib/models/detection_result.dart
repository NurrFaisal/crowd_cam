class DetectionResult {
  final String detectionId;
  final String missingPersonId;
  final String cameraUserId;
  final double confidenceScore;
  final String imageUrl;
  final DateTime detectedAt;
  final double latitude;
  final double longitude;
  final String location;

  DetectionResult({
    required this.detectionId,
    required this.missingPersonId,
    required this.cameraUserId,
    required this.confidenceScore,
    required this.imageUrl,
    required this.detectedAt,
    required this.latitude,
    required this.longitude,
    required this.location,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      detectionId: json['detection_id'],
      missingPersonId: json['missing_person_id'],
      cameraUserId: json['camera_user_id'],
      confidenceScore: json['confidence_score'].toDouble(),
      imageUrl: json['image_url'],
      detectedAt: DateTime.parse(json['detected_at']),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detection_id': detectionId,
      'missing_person_id': missingPersonId,
      'camera_user_id': cameraUserId,
      'confidence_score': confidenceScore,
      'image_url': imageUrl,
      'detected_at': detectedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
    };
  }
}