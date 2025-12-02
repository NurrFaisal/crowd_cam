# CrowdCam: Missing Person Detection System

CrowdCam is a distributed mobile application system that helps find missing persons through crowd-sourced face detection and recognition using phone cameras.

## Features

### Flutter Mobile App
- **Real-time face detection** using Google ML Kit
- **Camera integration** with automatic face scanning
- **Missing person registration** with photo upload
- **Distributed camera network** communication
- **Real-time notifications** for potential matches
- **Detection history** tracking
- **Location-based services** for geo-tagging detections

### Django Backend
- **Face recognition system** using face_recognition library
- **REST API** for mobile app communication
- **PostgreSQL database** for data storage
- **Real-time WebSocket** communication
- **Distributed camera network** management
- **Face encoding and matching** algorithms
- **Detection result processing** and verification

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Django Backend │    │   PostgreSQL   │
│                 │◄──►│                 │◄──►│    Database     │
│ • Face Detection│    │ • Face Recognition│   │ • Missing Persons│
│ • Camera        │    │ • REST API      │    │ • Detections    │
│ • Notifications │    │ • WebSockets    │    │ • Users         │
│ • Network Comm. │    │ • Image Processing│   │ • Face Encodings│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                        ▲                        ▲
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Redis Cache   │    │   File Storage  │    │   Push Notifications│
│                 │    │                 │    │                 │
│ • Session Data  │    │ • Photos        │    │ • Match Alerts  │
│ • WebSocket     │    │ • Detection     │    │ • Network Updates│
│ • Task Queue    │    │   Images        │    │ • System Alerts │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Installation & Setup

### Backend Setup (Django)

1. **Install Python dependencies:**
```bash
cd crowdcam_backend
pip install -r requirements.txt
```

2. **Install system dependencies:**
```bash
# For face_recognition library
sudo apt-get install cmake
sudo apt-get install libopenblas-dev liblapack-dev 
sudo apt-get install libx11-dev libgtk-3-dev

# For PostgreSQL
sudo apt-get install postgresql postgresql-contrib
```

3. **Database setup:**
```bash
# Create PostgreSQL database
sudo -u postgres createuser --interactive crowdcam_user
sudo -u postgres createdb crowdcam_db
```

4. **Environment configuration:**
```bash
# Create .env file
echo "DB_NAME=crowdcam_db" >> .env
echo "DB_USER=crowdcam_user" >> .env
echo "DB_PASSWORD=your_password" >> .env
echo "SECRET_KEY=your_secret_key" >> .env
```

5. **Run migrations:**
```bash
python manage.py makemigrations
python manage.py migrate
```

6. **Start the server:**
```bash
python manage.py runserver
```

### Frontend Setup (Flutter)

1. **Install Flutter dependencies:**
```bash
cd crowd_cam
flutter pub get
```

2. **Configure permissions (Android):**
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.VIBRATE" />
```

3. **Run the app:**
```bash
flutter run
```

## API Endpoints

### Missing Persons
- `GET /api/v1/missing-persons/` - List missing persons
- `POST /api/v1/missing-persons/` - Create missing person report
- `GET /api/v1/missing-persons/{id}/` - Get missing person details
- `POST /api/v1/missing-persons/{id}/deactivate/` - Deactivate missing person

### Face Recognition
- `POST /api/v1/face-recognition/detect/` - Submit image for face detection
- `GET /api/v1/face-recognition/detections/` - Get detection history
- `POST /api/v1/face-recognition/detections/{id}/verify/` - Verify detection

### Camera Network
- `POST /api/v1/camera/register/` - Register camera device
- `GET /api/v1/camera/nodes/` - List camera nodes
- `POST /api/v1/camera/nodes/{id}/heartbeat/` - Send heartbeat
- `GET /api/v1/camera/alerts/` - Get network alerts

## How It Works

1. **Registration:** Users can report missing persons by uploading photos and details
2. **Face Encoding:** The system extracts face encodings from uploaded photos
3. **Detection:** Camera users scan faces in real-time using their phone cameras
4. **Matching:** Detected faces are compared against the missing persons database
5. **Alerts:** When matches are found, notifications are sent to relevant parties
6. **Verification:** Human verification helps confirm or reject potential matches

## Security & Privacy

- All face encodings are stored securely and cannot be reverse-engineered
- Location data is optional and can be disabled by users
- Detection images are automatically deleted after processing
- No biometric data is stored on mobile devices

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Google ML Kit for face detection
- face_recognition library for face recognition
- Flutter team for the mobile framework
- Django team for the backend framework