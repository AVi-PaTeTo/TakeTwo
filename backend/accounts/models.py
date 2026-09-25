from django.contrib.auth.models import AbstractUser
from django.contrib.postgres.fields import ArrayField
from django.db import models

class User(AbstractUser):
    preferred_genres = ArrayField(
        models.IntegerField(),
        default=list,
        blank=True,
    )