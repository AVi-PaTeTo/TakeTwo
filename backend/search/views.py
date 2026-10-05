from django.contrib.auth import get_user_model
from django.db.models import Q
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from posts.models import Post
from posts.serializers import PostSerializer, UserSummarySerializer

User = get_user_model()


class SearchView(APIView):
    permission_classes = [IsAuthenticated]

    PAGE_SIZE = 10

    def get(self, request):
        query = (
            request.query_params.get("query")
            or request.query_params.get("q", "")
        ).strip()

        if not query:
            return Response({
                "users": {
                    "count": 0,
                    "next": None,
                    "results": [],
                },
                "posts": {
                    "count": 0,
                    "next": None,
                    "results": [],
                },
            })

        try:
            user_page = max(
                int(request.query_params.get("user_page", 1)),
                1,
            )
        except ValueError:
            user_page = 1

        try:
            post_page = max(
                int(request.query_params.get("post_page", 1)),
                1,
            )
        except ValueError:
            post_page = 1

        users = User.objects.filter(
            Q(username__icontains=query)
        ).order_by("username")

        posts = Post.objects.filter(
            Q(title__icontains=query)
            | Q(content__icontains=query)
            | Q(movie__title__icontains=query)
        ).select_related(
            "user",
            "movie",
        ).order_by("-created_at")

        users_data = self._paginate(
            queryset=users,
            page=user_page,
        )

        posts_data = self._paginate(
            queryset=posts,
            page=post_page,
        )

        return Response({
            "users": users_data,
            "posts": posts_data,
        })

    def _paginate(self, queryset, page):
        page_size = self.PAGE_SIZE

        count = queryset.count()

        start = (page - 1) * page_size
        end = start + page_size

        results = queryset[start:end]

        if queryset.model == User:
            results_data = UserSummarySerializer(
                results,
                many=True,
                context={"request": self.request},
            ).data
        else:
            results_data = PostSerializer(
                results,
                many=True,
                context={"request": self.request},
            ).data

        next_page = (
            page + 1
            if end < count
            else None
        )

        return {
            "count": count,
            "next": next_page,
            "results": results_data,
        }