from django.contrib.auth import get_user_model
from rest_framework import serializers
from rest_framework.pagination import PageNumberPagination

from posts.models import Post
from social.models import Follow
from posts.serializers import PostSerializer

User = get_user_model()

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta: 
        model = User
        fields = [ 'username', 'email', 'password', 'preferred_genres']

    def validate_email(self, value):
        return value.strip().lower()

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)
    
    def validate_preferred_genres(self, value):
        if len(value) < 5:
            raise serializers.ValidationError(
                "Select at least 5 genres."
            )

        return value

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'preferred_genres']

class UserPostPagination(PageNumberPagination):
    page_size = 15
    page_size_query_param = 'page_size'
    max_page_size = 50

class UserDetailSerializer(serializers.ModelSerializer):
    post_count = serializers.IntegerField(read_only=True)
    follower_count = serializers.IntegerField(read_only=True)
    following_count = serializers.IntegerField(read_only=True)
    is_following = serializers.SerializerMethodField()
    posts = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            "id",
            "username",
            "preferred_genres",
            "post_count",
            "follower_count",
            "following_count",
            "is_following",
            "posts",
        ]

    def get_is_following(self, obj):
        request = self.context["request"]
        user = request.user

        if user == obj:
            return False

        return obj.followers.filter(follower=user).exists()

    def get_posts(self, obj):
        request = self.context.get("request")
        posts = obj.posts.select_related("user", "movie").all()

        paginator = UserPostPagination()
        paginated_posts = paginator.paginate_queryset(posts, request, view=self)

        serializer = PostSerializer(
            paginated_posts,
            many=True,
            context=self.context,
        )
        return paginator.get_paginated_response(serializer.data).data