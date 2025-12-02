from django.shortcuts import redirect

def home(request):
    return redirect('admin:index')  # Redirects to the admin dashboard


