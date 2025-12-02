# CrowdCam - Phone Setup Guide

## Quick Setup for Your Phone

### Prerequisites
1. Android phone with USB debugging enabled
2. Computer with Flutter installed
3. USB cable to connect phone to computer

### Step-by-Step Setup

#### 1. Enable Developer Mode on Your Phone
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times
3. Go back to **Settings** → **Developer Options**
4. Enable **USB Debugging**

#### 2. Install Flutter on Your Computer
```bash
# Download Flutter SDK
# Visit: https://flutter.dev/docs/get-started/install

# Add to PATH (Linux/Mac)
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### 3. Setup Project
```bash
# Navigate to the project
cd crowd_cam

# Install dependencies
flutter pub get

# Check connected devices
flutter devices
```

#### 4. Run on Phone
```bash
# Connect phone via USB and run
flutter run
```

### Alternative: APK Installation
If you can't install Flutter, I can help create an APK file:

1. Build the APK:
```bash
flutter build apk --release
```

2. Transfer the APK to your phone:
```bash
# APK will be in: build/app/outputs/flutter-apk/app-release.apk
```

3. Install on phone:
   - Enable "Install from Unknown Sources"
   - Install the APK file

### Backend Setup (Optional)
For full functionality, run the Django backend:

```bash
cd crowdcam_backend
pip install django djangorestframework
python manage.py runserver 0.0.0.0:8000
```

### What You'll See on Your Phone
- 📱 Camera screen with real-time face detection
- 👥 Missing persons database browser
- 📝 Form to report missing persons
- 🔔 Notification system for alerts
- 📍 Location-based services

### Troubleshooting
- If phone not detected: Check USB debugging is enabled
- If build fails: Run `flutter doctor` to check setup
- If camera doesn't work: Grant camera permissions when prompted
- If location doesn't work: Grant location permissions

### Demo Mode
The app includes demo data and can run without the backend for testing purposes.