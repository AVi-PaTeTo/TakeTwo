from rest_framework import serializers

from .models import Movie

class MovieSerializer(serializers.ModelSerializer):
    class Meta:
        model = Movie
        fields = [
            'id', 'tmdb_id', 'media_type', 'title', 'overview', 'poster_path', 'backdrop_path', 'release_date', 'genre_ids', 'trailer_url'
        ]