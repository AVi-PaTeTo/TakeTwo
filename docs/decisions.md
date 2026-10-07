# Technical Decisions

This document records the main engineering decisions behind Take Two and
the reasoning for them.

## 1. Flutter for the Mobile Client

Take Two uses Flutter and Dart for the mobile application.

The project was intentionally built as a mobile-first experience because
the product is centered around browsing a visual social feed.

Flutter also allowed the application to maintain a consistent visual
system across screens without maintaining separate native Android and
iOS implementations.

------------------------------------------------------------------------

## 2. Django REST Framework for the Backend

The backend uses Django REST Framework.

Django provides a mature structure for:

-   Authentication
-   Database models
-   Serializers
-   API views
-   Relationships
-   Pagination
-   Validation

The backend is separated into domain-focused Django apps such as
accounts, movies, posts, search, and social.

------------------------------------------------------------------------

## 3. TMDB as the Movie Data Source

Take Two does not attempt to maintain its own complete movie database.

TMDB provides movie and TV metadata such as:

-   Titles
-   Posters
-   Backdrops
-   Release dates
-   Genres
-   Overviews
-   Trailer-related information

Relevant TMDB information is stored in the application's own movie model
so that posts can reference a stable local record.

This allows the social layer to remain independent from the external
API.

------------------------------------------------------------------------

## 4. Separate Movie and TV Media Types

TMDB movie and TV results can share numeric IDs, so the application does
not treat a TMDB ID by itself as enough information to identify a title.

The media type (`movie` or `tv`) is therefore passed explicitly through
the create/search flow.

The Flutter create state is the source of truth for the currently
selected media type.

This prevents a TV show from accidentally being resolved as a movie when
the numeric TMDB ID happens to overlap.

------------------------------------------------------------------------

## 5. Riverpod for State Management

Riverpod is used to separate UI from application state and API services.

The general flow is:

``` text
Widget / Screen
      ↓
Riverpod Provider
      ↓
Service
      ↓
API Client
      ↓
Django REST API
```

Providers handle state and coordinate application behavior while
services handle network operations.

This keeps widgets from becoming responsible for API communication and
business logic.

------------------------------------------------------------------------

## 6. Normalized Post State

Posts are stored in normalized client-side state.

Instead of allowing Home, Search, Explore, and Post Detail to maintain
unrelated copies of the same post, they can reference the shared post
state by ID.

``` text
Post ID
   ↓
Shared Post State
   ├── Home
   ├── Search
   ├── Explore
   └── Post Detail
```

This was chosen because posts are highly interactive.

A like or comment count can change while the user moves between screens,
so having a shared source of truth prevents stale UI.

------------------------------------------------------------------------

## 7. Optimistic Updates

Likes and other fast interactions use optimistic UI updates where
appropriate.

The UI changes immediately while the API request is processed.

This makes the application feel responsive instead of forcing the user
to wait for a round trip to the backend before seeing feedback.

The shared normalized state is then updated according to the result of
the operation.

------------------------------------------------------------------------

## 8. Pagination and Infinite Scrolling

Large collections are paginated on the backend and loaded progressively
by the Flutter application.

This is used for areas such as:

-   Home
-   Explore
-   Search results

Search maintains independent pagination for users and posts so loading
more users does not unnecessarily affect the posts result set.

------------------------------------------------------------------------

## 9. Debounced Search

Search input is debounced before making API requests.

``` text
User types
    ↓
Short debounce period
    ↓
API request
    ↓
Results
```

Without debouncing, every keystroke could generate a network request.

Debouncing reduces unnecessary traffic while retaining responsive
search.

------------------------------------------------------------------------

## 10. Image Caching and Explore Preloading

Explore is visually dominated by large poster and backdrop images.

Simply caching images was not enough to make navigation feel
consistently smooth because the next page itself could still require
construction.

The Explore implementation therefore preloads upcoming content as well
as movie artwork.

This reduces the amount of visible work when the user swipes to the next
item.

------------------------------------------------------------------------

## 11. Cloudinary for Uploaded Images

User-uploaded images are stored using **Cloudinary**.

This includes application media such as profile pictures and uploaded
post imagery.

Cloudinary was chosen instead of relying on the backend server's local
filesystem because persistent media storage should be separated from the
application server.

This is especially important when deploying the Django backend to
infrastructure where the local filesystem may be ephemeral.

------------------------------------------------------------------------

## 12. Feature-Based Flutter Structure

The Flutter project is organized around product features:

``` text
features/
├── auth/
├── home/
├── explore/
├── create/
├── search/
└── profile/
```

Shared models and providers live outside individual features when they
are used across multiple parts of the application.

This keeps related UI, providers, models, and services close together
while avoiding unnecessary duplication.

------------------------------------------------------------------------

## 13. GoRouter for Navigation

GoRouter manages application navigation and route-level behavior.

It supports:

-   Authentication redirects
-   Nested navigation
-   Profile routes
-   Post detail routes
-   User detail routes
-   Deep links within the application

The application's primary navigation uses a shell so the main navigation
remains available on the relevant top-level screens.

------------------------------------------------------------------------

## 14. Backend as the Source of Truth

The backend remains the authoritative source for persistent application
data.

Flutter state is used for presentation, caching, and responsive
interactions, but persistent entities such as:

-   Users
-   Posts
-   Likes
-   Comments
-   Follows
-   Movies

are ultimately stored and validated by the backend.

This keeps the client from becoming the authority for application data.

------------------------------------------------------------------------

## 15. Reusable UI Components

Common UI elements are implemented as reusable widgets where practical.

For example, post presentation is shared instead of creating completely
different post implementations for every screen.

This keeps the visual language consistent and makes UI changes easier to
apply globally.

------------------------------------------------------------------------

## 16. Loading, Error, and Empty States

Network-driven screens explicitly handle:

-   Initial loading
-   Pagination loading
-   Empty results
-   Network/API failures
-   Retry actions

This was treated as part of the normal product experience rather than
assuming every request succeeds.

------------------------------------------------------------------------

## 17. Why These Decisions Matter

The goal was not simply to make the MVP functional.

The architecture was designed around the characteristics of the product:

-   A highly interactive social feed benefits from normalized state.
-   A visual discovery feed benefits from caching and preloading.
-   Search benefits from debouncing and independent pagination.
-   Mobile interactions benefit from optimistic updates.
-   User-generated media benefits from dedicated cloud storage.
-   A growing Flutter project benefits from feature-based organization.
