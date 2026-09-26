from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status

from .serializers import MovieSerializer
from .services import TMDBClient

import requests

class MovieSearchView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        query = request.query_params.get("query", "").strip()

        if not query:
            return Response(
                {"error": "Query parameter is required."},
                status=400
            )
        client = TMDBClient()
        data = client.search_movies(query)

        return Response(data)

class MovieDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, tmdb_id):
        media_type = request.query_params.get("type")

        if media_type not in ["movie", "tv"]:
            return Response(
                {"error": "type must be a 'movie' or 'tv'."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        client = TMDBClient()

        try:
            data = client.get_details(tmdb_id, media_type)
            movie, _ = client.save_movie(data, media_type)
        except requests.HTTPError:
            return Response(
                {"error": "Movie not found on TMDB."},
                status=status.HTTP_404_NOT_FOUND,
            )

        return Response(MovieSerializer(movie).data)

class GenreListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        client = TMDBClient()

        try:
            genres = client.get_genres()
        except requests.HTTPError:
            return Response(
                {"error": "Failed to fetch genres from TMDB."},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        return Response(genres)