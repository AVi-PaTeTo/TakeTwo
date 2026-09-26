from django.urls import path

from .views import MovieSearchView, MovieDetailView, GenreListView

urlpatterns = [
    path("search/", MovieSearchView.as_view(), name="movie-search"),
    path("<int:tmdb_id>/", MovieDetailView.as_view(), name="movie_detail"),
    path("genres/",GenreListView.as_view(),name="genre-list"),
]