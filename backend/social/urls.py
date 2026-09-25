from django.urls import path

from .views import FollowView, UserSuggestionsView

urlpatterns = [
    path(
        "users/suggestions/",
        UserSuggestionsView.as_view(),
        name="user-suggestions",
    ),

    path(
        "users/<int:user_id>/follow/",
        FollowView.as_view(),
        name="follow-user"
        )
]