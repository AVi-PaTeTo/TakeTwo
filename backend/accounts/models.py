from django.contrib.auth.models import AbstractUser
from django.contrib.postgres.fields import ArrayField
from django.db import models

class User(AbstractUser):
    
    username = models.CharField(
        max_length=25,
        unique=True,
        help_text='Required. 25 characters or fewer. Letters, digits and @/./+/-/_ only.',
        validators=[AbstractUser.username_validator],
        error_messages={
            'unique': 'A user with that username already exists.',
        },
    )

    preferred_genres = ArrayField(
        models.IntegerField(),
        default=list,
        blank=True,
    )

    profile_picture_url = models.URLField(
        max_length=500,
        blank=True,
        null=True,
    )

    profile_banner_url = models.URLField(
        max_length=500,
        blank=True,
        null=True,
    )