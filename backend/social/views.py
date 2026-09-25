from django.contrib.auth import get_user_model
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Follow
from .serializers import SuggestedUserSerializer

User = get_user_model()

class UserSuggestionsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user

        following_ids = Follow.objects.filter(
            follower=user
        ).values_list(
            "following_id",
            flat=True,
        )

        candidates = (
            User.objects
            .exclude(id=user.id)
            .exclude(id__in=following_ids)
        )

        suggestions = []

        for candidate in candidates:
            shared_genres = len(
                set(user.preferred_genres)
                & set(candidate.preferred_genres)
            )

            if shared_genres > 0:
                candidate.shared_genres = shared_genres
                suggestions.append(candidate)

        suggestions.sort(
            key=lambda user: user.shared_genres,
            reverse=True,
        )

        suggestions = suggestions[:10]

        serializer = SuggestedUserSerializer(
            suggestions,
            many=True,
        )

        return Response(serializer.data)

class FollowView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, user_id):

        if request.user.id == user_id:
            return Response(
                {"error": "you cannot follow yourself."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            user_to_follow = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {"error": "User not found."},
                status=status.HTTP_400_NOT_FOUND,
            )

        follow, created = Follow.objects.get_or_create(
            follower = request.user,
            following = user_to_follow
        )

        if not created:
            return Response(
                {"error": "Already following this user."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        return Response(
            {"message": "User followed successfully."},
            status=status.HTTP_201_CREATED,
        )

    def delete(self, request, user_id):
        deleted, _ = Follow.objects.filter(
            follower = request.user,
            following = user_id
        ).delete()

        if deleted == 0:
            return Response(
                {"error": "You are not following this user."},
                status=status.HTTP_400_NOT_FOUND,
            )

        return Response(status=status.HTTP_204_NO_CONTENT)