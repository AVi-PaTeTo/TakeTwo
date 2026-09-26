# Architecture Decisions

## 001 — Flutter + Django

Flutter is used for the mobile client because the target internship
specifically involves Flutter.

Django + DRF is used for the backend because the target internship
specifically mentions Django.

## 002 — TMDB

Movie metadata comes from TMDB rather than being manually entered.

## 003 — Separate PostLike and CommentLike

Likes use separate tables rather than a polymorphic parentId because
we want explicit foreign keys and database-enforced relationships.

## Movie data

TMDB is used as the external source for movie/TV metadata.
The backend stores movies referenced by posts so posts don't depend
on repeatedly querying TMDB.

## Likes

PostLike and CommentLike are separate models rather than a polymorphic
Like model.

## Comments

Replies are stored as direct children of the root comment.
reply_to identifies the user being directly addressed.

This gives the UI Instagram-style reply behavior without creating
arbitrarily deep database nesting.

## Feed

Home contains posts from the current user and users they follow.

Explore contains posts whose movie genres overlap with the user's
preferred genres.

Horizontal Explore navigation shows other posts belonging to the
same movie.
