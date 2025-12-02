class MissingPerson {
  final String id;
  final String name;
  final int age;
  final String description;
  final String photoUrl;
  final DateTime lastSeenDate;
  final String lastSeenLocation;
  final String contactInfo;
  final bool isActive;
  final DateTime reportedDate;

  MissingPerson({
    required this.id,
    required this.name,
    required this.age,
    required this.description,
    required this.photoUrl,
    required this.lastSeenDate,
    required this.lastSeenLocation,
    required this.contactInfo,
    this.isActive = true,
    required this.reportedDate,
  });

  factory MissingPerson.fromJson(Map<String, dynamic> json) {
    return MissingPerson(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      description: json['description'],
      photoUrl: json['photo_url'],
      lastSeenDate: DateTime.parse(json['last_seen_date']),
      lastSeenLocation: json['last_seen_location'],
      contactInfo: json['contact_info'],
      isActive: json['is_active'] ?? true,
      reportedDate: DateTime.parse(json['reported_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'description': description,
      'photo_url': photoUrl,
      'last_seen_date': lastSeenDate.toIso8601String(),
      'last_seen_location': lastSeenLocation,
      'contact_info': contactInfo,
      'is_active': isActive,
      'reported_date': reportedDate.toIso8601String(),
    };
  }
}