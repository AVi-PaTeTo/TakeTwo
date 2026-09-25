from django.contrib.auth import get_user_model
from rest_framework import serializers

User = get_user_model()


class SuggestedUserSerializer(serializers.ModelSerializer):
    shared_genres = serializers.IntegerField(read_only=True)

    class Meta:
        model = User
        fields = [
            "id",
            "username",
            "shared_genres",
        ]