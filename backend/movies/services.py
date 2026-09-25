import requests
from .models import Movie
from django.conf import settings

TMDB_BASE_URL = "https://api.themoviedb.org/3"

class TMDBClient:
    def __init__(self):
        self.headers = {
            "Authorization": f"Bearer {settings.TMDB_API_TOKEN}",
            "accept": "application/json"
        }

    def search_movies(self, query):
        response = requests.get(
            f"{TMDB_BASE_URL}/search/movie",
            headers=self.headers,
            params={"query": query,
                    "include_adult": True,
                    "language": "en-US",
                    "page": 1},
            timeout=10,
            
        )

        response.raise_for_status()

        return response.json()

    def get_details(self,tmdb_id, media_type):
        response = requests.get(
            f"{TMDB_BASE_URL}/{media_type}/{tmdb_id}",
            headers=self.headers,
            params={"append_to_response":"videos"},
            timeout=10,
        )

        response.raise_for_status()

        return response.json()

    def normalise_details(self, data, media_type):
        if media_type == "movie":
            title = data.get("title", "")
            release_date = data.get("release_data") or None
        else:
            title = data.get("name", "")
            release_date = data.get("first_air_date") or None

        return{
            "tmdb_id": data["id"],
            "media_type": media_type,
            "title": title,
            "overview": data.get("overview", ""),
            "poster_path": data.get("poster_path") or "",
            "backdrop_path": data.get("backdrop_path") or "",
            "release_date": release_date,
            "genre_ids": [
                genre["id"]
                for genre in data.get("genres", [])
            ],
        }

    def save_movie(self, data, media_type):
        movie_data = self.normalise_details(data, media_type)

        movie, created = Movie.objects.update_or_create(
            tmdb_id=movie_data["tmdb_id"],
            media_type=movie_data["media_type"],
            defaults=movie_data
        )

        return movie, created