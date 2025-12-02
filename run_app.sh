#!/bin/bash

echo "🔍 CrowdCam - Missing Person Detection System"
echo "=============================================="
echo ""

# Check if required tools are installed
check_installation() {
    local tool=$1
    local name=$2
    
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $name is installed"
        return 0
    else
        echo "❌ $name is not installed"
        return 1
    fi
}

echo "📋 Checking system requirements..."
echo ""

# Check Python
if check_installation python3 "Python 3"; then
    python_version=$(python3 --version)
    echo "   Version: $python_version"
fi

# Check Django
if python3 -c "import django; print('   Version:', django.get_version())" 2>/dev/null; then
    echo "✅ Django is installed"
else
    echo "❌ Django is not installed"
    echo "   Install with: pip install django"
fi

# Check Flutter
if check_installation flutter "Flutter"; then
    flutter_version=$(flutter --version | head -n1)
    echo "   $flutter_version"
fi

# Check PostgreSQL
if check_installation psql "PostgreSQL"; then
    pg_version=$(psql --version)
    echo "   $pg_version"
fi

echo ""
echo "📱 To run the CrowdCam app:"
echo ""
echo "1️⃣  Backend Setup (Django):"
echo "   cd crowdcam_backend"
echo "   pip install -r requirements.txt"
echo "   python manage.py makemigrations"
echo "   python manage.py migrate"
echo "   python manage.py runserver"
echo ""
echo "2️⃣  Frontend Setup (Flutter):"
echo "   cd crowd_cam"
echo "   flutter pub get"
echo "   flutter run"
echo ""
echo "🌟 Features Available:"
echo "   • Real-time face detection using phone camera"
echo "   • Missing person registration with photos"
echo "   • Distributed camera network communication"
echo "   • Push notifications for potential matches"
echo "   • Detection history tracking"
echo "   • Location-based services"
echo ""
echo "🔗 API Endpoints:"
echo "   • GET  /api/v1/missing-persons/     - List missing persons"
echo "   • POST /api/v1/missing-persons/     - Report missing person"
echo "   • POST /api/v1/face-recognition/detect/ - Submit detection"
echo "   • GET  /api/v1/camera/nodes/        - Camera network status"
echo ""
echo "📚 For detailed setup instructions, see README.md"