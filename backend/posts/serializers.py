from rest_framework import serializers
from django.contrib.auth import get_user_model

from movies.serializers import MovieSerializer
from movies.models import Movie

from .models import Post, Comment, PostLike, CommentLike

User = get_user_model()

class UserSummarySerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "username", "profile_picture_url"]

class PostSerializer(serializers.ModelSerializer):
    user = UserSummarySerializer(read_only=True)
    
    movie = MovieSerializer(read_only=True)
    movie_id = serializers.PrimaryKeyRelatedField(
        queryset=Movie.objects.all(),
        source="movie",
        write_only=True,
    )

    like_count = serializers.IntegerField(
        source="likes.count",
        read_only=True,
    )

    comment_count = serializers.IntegerField(
        source="comments.count",
        read_only=True,
    )

    is_liked = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = [
            "id",
            "user",
            "movie",
            "movie_id",
            "title",
            "content",
            "custom_poster_url",
            "banner_url",
            "like_count",
            "comment_count",
            "is_liked",
            "created_at",
            "updated_at",
        ]

        read_only_fields = [
            "id",
            "user",
            "movie",
            "like_count",
            "comment_count",
            "is_liked",
            "created_at",
            "updated_at",
        ]

    def get_is_liked(self,obj):
        user = self.context["request"].user
        return obj.likes.filter(user=user).exists()

class CommentSerializer(serializers.ModelSerializer):
    user = UserSummarySerializer(read_only=True)
    reply_to = UserSummarySerializer(read_only=True)

    replies = serializers.SerializerMethodField()

    like_count = serializers.IntegerField(
        source="likes.count",
        read_only=True
    )

    is_liked = serializers.SerializerMethodField()

    class Meta:
        model = Comment
        fields = [
            "id",
            "user",
            "reply_to",
            "replies",
            "content",
            "like_count",
            "is_liked",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "user",
            "reply_to",
            "replies",
            "like_count",
            "created_at",
            "updated_at",
        ]

    def get_replies(self, obj):
        return CommentSerializer(
            obj.replies.all(),
            many=True,
            context=self.context,
        ).data

    def get_is_liked(self, obj):
        request = self.context.get("request")
        
        if not request or not request.user.is_authenticated:
            return False

        return obj.likes.filter(user=request.user).exists()