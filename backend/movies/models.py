from django.db import models

class Movie(models.Model):
    class MediaType(models.TextChoices):
        MOVIE = "movie", "Movie"
        TV = "tv", "TV"

    tmdb_id = models.PositiveIntegerField()
    media_type = models.CharField(
        max_length=10,
        choices=MediaType.choices,
        )

    title = models.CharField(max_length=255)
    overview = models.TextField(blank=True)

    poster_path = models.CharField(max_length=255, blank=True)
    backdrop_path =  models.CharField(max_length=255, blank=True)

    release_date = models.DateField(null=True, blank=True)

    genre_ids = models.JSONField(default=list)

    trailer_url = models.URLField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["tmdb_id", "media_type"],
                name="unique_tmdb_media"
            )
        ]

    def __str__(self):
        return self.title
    