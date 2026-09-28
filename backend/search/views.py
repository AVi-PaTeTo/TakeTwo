from django.db.models import Q
from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from accounts.models import User

from posts.models import Post
from posts.serializers import PostSerializer, UserSummarySerializer

class SearchView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        query = request.query_params.get("q", "").strip()

        if not query:
            return Response({
                "users": [],
                "posts": [],
            })

        users = User.objects.filter(
            username__icontains=query
        )[:10]

        posts = Post.objects.filter(
            Q(title__icontains=query)
            | Q(content__icontains=query)
            | Q(movie__title__icontains=query)
        ).select_related(
            "user",
            "movie",
        )[:20]

        return Response({
            "users": UserSummarySerializer(
                users,
                many=True,
            ).data,

            "posts": PostSerializer(
                posts,
                many=True,
                context={"request": request},
            ).data,
        })