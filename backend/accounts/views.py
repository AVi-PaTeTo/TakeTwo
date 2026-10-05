from rest_framework import generics, permissions, status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Count
import cloudinary

from django.contrib.auth import get_user_model
from .serializers import    (
                            RegisterSerializer, 
                            UserSerializer, 
                            UserDetailSerializer, 
                            UserProfileUpdateSerializer, 
                            ChangePasswordSerializer
                            )

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]

class MeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

class UserDetailView(generics.RetrieveAPIView):
    serializer_class = UserDetailSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return (
            User.objects
            .annotate(
                post_count=Count("posts", distinct=True),
                follower_count=Count("followers", distinct=True),
                following_count=Count("following", distinct=True),
            )
        )

class ChangePasswordView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = ChangePasswordSerializer(data=request.data)
        
        if serializer.is_valid():
            user = request.user
            old_password = serializer.validated_data['old_password']
            new_password = serializer.validated_data['new_password']

            if not user.check_password(old_password):
                return Response(
                    {"old_password": ["Incorrect old password."]}, 
                    status=status.HTTP_400_BAD_REQUEST
                )

            user.set_password(new_password)
            user.save()

            return Response(
                {"detail": "Password updated successfully."}, 
                status=status.HTTP_200_OK
            )
            
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserProfileUpdateView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileUpdateSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_object(self):
        return self.request.user

    def perform_update(self, serializer):
        user = self.request.user
        
        # Get files sent from Flutter
        profile_image = self.request.FILES.get('profile_picture')
        banner_image = self.request.FILES.get('banner_picture')
        
        profile_picture_url = user.profile_picture_url  # Keep existing by default
        profile_banner_url = user.profile_banner_url      # Keep existing by default (Fixed name)

        if profile_image:
            upload_result = cloudinary.uploader.upload(
                profile_image,
                folder="user_profiles"
            )
            profile_picture_url = upload_result.get("secure_url")

        if banner_image:
            upload_result = cloudinary.uploader.upload(
                banner_image,
                folder="user_banners"
            )
            profile_banner_url = upload_result.get("secure_url")

        serializer.save(
            profile_picture_url=profile_picture_url,
            profile_banner_url=profile_banner_url, # Fixed argument name to match serializer
        )