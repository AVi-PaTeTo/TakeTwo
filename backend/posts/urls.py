from django.urls import path

from .views import (
                    ExploreView,
                    MoviePostsView,
                    PostCreateView, 
                    PostListView, 
                    PostCommentsView, 
                    PostLikeView, 
                    CommentLikeView, 
                    CommentReplyView
                    )

urlpatterns = [
    path("", PostListView.as_view(), name="post-list"),
    path("create/", PostCreateView.as_view(), name="post-create"),

    path(
    "explore/",
    ExploreView.as_view(),
    name="explore",
    ),

    path(
    "movies/<int:movie_id>/posts/",
    MoviePostsView.as_view(),
    name="movie-posts",
    ),

    path(
        "<int:post_id>/like/",
        PostLikeView.as_view(),
        name="post-like",
    ),

    path(
        "<int:post_id>/comments/",
        PostCommentsView.as_view(),
        name="post-comments",
    ),

    path(
        "comments/<int:comment_id>/like/",
        CommentLikeView.as_view(),
        name="comment-like",
    ),

    path(
        "comments/<int:comment_id>/replies/",
        CommentReplyView.as_view(),
        name="comment-replies",
    ),
]