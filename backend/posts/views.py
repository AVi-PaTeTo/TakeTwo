from django.contrib.auth import get_user_model
from django.db.models import Q
from rest_framework.parsers import MultiPartParser, FormParser
import cloudinary.uploader

from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .pagination import PostPagination
from .models import Post, PostLike, Comment, CommentLike
from .serializers import PostSerializer, CommentSerializer

User = get_user_model()

class PostCreateView(generics.CreateAPIView):
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):

        banner_image = self.request.FILES.get('banner_image') # File sent from Flutter
        poster_image = self.request.FILES.get('poster_image') # File sent from Flutter
        poster_image_url = ''
        banner_image_url = ''

        if banner_image:
            # Upload to Cloudinary during post creation
            upload_result = cloudinary.uploader.upload(
                banner_image,
                folder="post_banners"
            )
            banner_image_url = upload_result.get("secure_url")

        if poster_image:
                    # Upload to Cloudinary during post creation
                    upload_result = cloudinary.uploader.upload(
                        poster_image,
                        folder="movie_posters"
                    )
                    poster_image_url = upload_result.get("secure_url")

        # Save the post along with the user and the uploaded image URL
        serializer.save(
            user=self.request.user,
            banner_url=banner_image_url,
            custom_poster_url=poster_image_url,
        )

class PostListView(generics.ListAPIView):
    serializer_class = PostSerializer
    pagination_class = PostPagination
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user 
        return (
            Post.objects
            .filter(
                Q(user=user) |
                Q(user__followers__follower=user)
            )
            .select_related("user","movie")
            .prefetch_related("likes","comments")
            .distinct()
            .order_by("-created_at")
            )

class PostLikeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        try:
            post = Post.objects.get(id=post_id)
        except Post.DoesNotExist:
            return Response(
                {"error": "Post not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        like, created = PostLike.objects.get_or_create(
            user=request.user,
            post=post,
        )

        if not created:
            return Response(
                {"error": "Post already liked."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        return Response(
            {"message": "Post liked successfully."},
            status=status.HTTP_201_CREATED,
        )

    def delete(self, request, post_id):
        deleted, _ = PostLike.objects.filter(
            user=request.user,
            post_id=post_id,
        ).delete()

        if deleted == 0:
            return Response(
                {"error": "Post is not liked."},
                status=status.HTTP_404_NOT_FOUND,
            )

        return Response(status=status.HTTP_204_NO_CONTENT)

class PostCommentsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, post_id):
        comments = (
                    Comment.objects
                    .filter(post_id=post_id, parent__isnull=True)
                    .select_related("user", "reply_to")
                    .prefetch_related(
                        "replies__user",
                        "replies__reply_to",
                        "replies__likes",
                    )
                    .order_by("created_at")
                )

        serializer = CommentSerializer(comments, many=True, context={"request": request},)

        return Response(serializer.data)

    def post(self, request, post_id):
        try:
            post = Post.objects.get(id=post_id)
        except Post.DoesNotExist:
            return Response(
                {"error": "Post not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = CommentSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save(
                user=request.user,
                post=post,
            )

            return Response(
                serializer.data,
                status=status.HTTP_201_CREATED,
            )

        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST,
        )

class CommentReplyView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, comment_id):
        try:
            comment = Comment.objects.select_related("post","user", "parent").get(
                id=comment_id
            )
        except Comment.DoesNotExist:
            return Response(
                {"error": "Comment not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        reply_to_id = request.data.get("reply_to")
        if not reply_to_id:
            return Response(
                {"error": "reply_to is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Find the user being replied to.
        try:
            reply_to = User.objects.get(id=reply_to_id)
        except User.DoesNotExist:
            return Response(
                {"error": "User not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Prevent the user to reply to themself
        if reply_to.id == request.user.id:
            return Response(
                {"error": "You cannot reply to yourself."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        # The root comment author is automatically a participant.
        root_comment = (
            comment.parent
            if comment.parent_id is not None
            else comment
        )

        # The root comment author is automatically a participant.
        is_root_author = (
            reply_to.id == root_comment.user_id
        )

        # Otherwise, check whether they have a comment/reply
        # in this thread.
        is_thread_participant = Comment.objects.filter(
            post=comment.post,
            parent=root_comment,
            user=reply_to,
        ).exists()

        if not is_root_author and not is_thread_participant:
            return Response(
                {
                    "error": (
                        "User is not part of this comment thread."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        serializer = CommentSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save(
                user=request.user,
                post=comment.post,
                parent=root_comment,
                reply_to=reply_to,
            )

            return Response(
                serializer.data,
                status=status.HTTP_201_CREATED,
            )

        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST,
        )

class CommentLikeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, comment_id):
        try:
            comment = Comment.objects.get(id=comment_id)
        except Comment.DoesNotExist:
            return Response(
                {"error": "Comment not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        like, created = CommentLike.objects.get_or_create(
            user=request.user,
            comment=comment,
        )

        if not created:
            return Response(
                {"error": "Comment already liked."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        return Response(
            {"message": "Comment liked successfully."},
            status=status.HTTP_201_CREATED,
        )

    def delete(self, request, comment_id):
        deleted, _ = CommentLike.objects.filter(
            user=request.user,
            comment_id=comment_id,
        ).delete()

        if deleted == 0:
            return Response(
                {"error": "Comment is not liked."},
                status=status.HTTP_404_NOT_FOUND,
            )

        return Response(status=status.HTTP_204_NO_CONTENT)

class ExploreView(generics.ListAPIView):
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = PostPagination

    def get_queryset(self):
        user = self.request.user

        genre_filters = Q()

        for genre_id in user.preferred_genres:
            genre_filters |= Q(movie__genre_ids__contains=[genre_id])

        return (
            Post.objects
            .filter(genre_filters)
            .select_related("user", "movie")
            .prefetch_related("likes", "comments")
            .distinct()
            .order_by("-created_at")
        )

class MoviePostsView(generics.ListAPIView):
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        movie_id = self.kwargs["movie_id"]

        return (
            Post.objects
            .filter(movie_id=movie_id)
            .select_related("user", "movie")
            .prefetch_related("likes", "comments")
            .order_by("-created_at")
        )

