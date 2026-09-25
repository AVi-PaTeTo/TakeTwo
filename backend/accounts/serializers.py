from django.contrib.auth import get_user_model
from rest_framework import serializers

User = get_user_model()

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta: 
        model = User
        fields = [ 'username', 'email', 'password', 'preferred_genres']

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