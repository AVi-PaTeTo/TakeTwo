# Architecture

## Overview

Take Two is a full-stack mobile social application built with Flutter on
the client and Django REST Framework on the backend.

The application also integrates with external services for movie
metadata and media storage.

```text
                         ┌──────────────────┐
                         │   Flutter App    │
                         │                  │
                         │ Auth             │
                         │ Home             │
                         │ Explore          │
                         │ Create           │
                         │ Search           │
                         │ Profile          │
                         └────────┬─────────┘
                                  │
                         HTTP / JSON API
                                  │
                                  ▼
                         ┌──────────────────┐
                         │  Django REST API │
                         │                  │
                         │ Accounts         │
                         │ Movies           │
                         │ Posts            │
                         │ Search           │
                         │ Social           │
                         └──────┬─────┬─────┘
                                │     │
                       ┌────────┘     └─────────┐
                       ▼                        ▼
                ┌──────────────┐        ┌──────────────┐
                │  PostgreSQL  │        │    TMDB      │
                │              │        │     API      │
                └──────────────┘        └──────────────┘

                         ┌──────────────────┐
                         │    Cloudinary    │
                         │ Uploaded images  │
                         └──────────────────┘
```

---

# Flutter Architecture

The Flutter application uses a feature-based structure.

```text
lib/
├── core/
│   ├── network/
│   ├── router/
│   └── ...
│
├── features/
│   ├── auth/
│   ├── home/
│   ├── explore/
│   ├── create/
│   ├── search/
│   └── profile/
│
└── shared/
    ├── models/
    ├── providers/
    └── ...
```

## Feature Layer

Each feature contains the UI and supporting code for a particular part
of the application.

For example:

```text
features/create/
├── models/
├── providers/
├── services/
├── screens/
└── widgets/
```

The exact contents vary by feature.

---

## Provider / Service Separation

The main client-side data flow is:

```text
┌───────────────┐
│    Screen     │
└───────┬───────┘
        │ watches / calls
        ▼
┌───────────────┐
│    Provider   │
└───────┬───────┘
        │ uses
        ▼
┌───────────────┐
│    Service    │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│   API Client  │
└───────┬───────┘
        │
        ▼
     Backend
```

### Screens

Screens are responsible primarily for presentation and user interaction.

### Providers

Providers hold application state and coordinate operations that affect
that state.

### Services

Services encapsulate API requests and transform network responses into
application models.

### Models

Models provide typed Dart representations of API data and are
responsible for JSON parsing through methods such as `fromJson`.

---

# Navigation Architecture

GoRouter manages navigation and authentication redirects.

The application has primary sections such as:

```text
Home
Explore
Create
Search
Profile
```

The main sections use shell-based navigation so the primary navigation
remains available while navigating within those areas.

Some routes, such as individual user profiles and post details, exist
outside the primary shell when the navigation should temporarily leave
the main navigation context.

---

# State Architecture

## Authentication State

Authentication state determines whether the application should display
authenticated or unauthenticated routes.

The access token is stored securely on the device.

The router uses authentication state to redirect users to the
appropriate screen.

---

## Post State

Posts use normalized state.

Conceptually:

```text
                    ┌─────────────┐
                    │ Post Cache  │
                    └──────┬──────┘
                           │
             ┌─────────────┼─────────────┐
             ▼             ▼             ▼
           Home         Search        Explore
                           │
                           ▼
                     Post Detail
```

A post can therefore be updated in one place and reflected throughout
the application.

This is particularly useful for likes and comments.

---

# Backend Architecture

The Django backend is divided into domain-specific applications.

```text
backend/
├── accounts/
├── movie/
├── posts/
├── search/
├── social/
└── ...
```

## Accounts

Responsible for:

- Registration
- Authentication
- Current-user data
- User profiles
- Profile updates

Routes include:

```text
/api/auth/register/
/api/auth/login/
/api/auth/refresh/
/api/auth/me/
/api/auth/users/{id}/
/api/auth/profile/update/
```

---

## Movie

Responsible for:

- Movie/TV search
- Movie/TV records
- Genre data
- TMDB integration

Routes include:

```text
/api/movies/search/
/api/movies/{tmdb_id}/
/api/movies/genres/
```

The backend stores relevant TMDB information locally so social posts can
reference an application-owned movie record.

---

## Posts

Responsible for:

- Feed
- Post creation
- Explore
- Posts associated with movies
- Likes
- Comments
- Comment likes
- Replies

Routes include:

```text
/api/posts/
/api/posts/create/
/api/posts/explore/
/api/posts/movies/{movie_id}/posts/
/api/posts/{post_id}/like/
/api/posts/{post_id}/comments/
/api/posts/comments/{comment_id}/like/
/api/posts/comments/{comment_id}/replies/
```

---

## Search

Search is separated from the main post and account domains.

```text
/api/search/?query={query}
```

The endpoint returns users and posts and supports separate pagination
for those result sets.

---

## Social

Responsible for relationships between users.

```text
/api/users/suggestions/
/api/users/{user_id}/follow/
```

Suggestions can use shared preferred genres to identify potentially
relevant users.

---

# Data Flow: Creating a Post

```text
User
 │
 │ searches for movie / TV show
 ▼
Flutter Create Provider
 │
 ▼
Create Service
 │
 ▼
Django Movie API
 │
 ▼
TMDB
 │
 ▼
Movie stored / retrieved
 │
 ▼
Flutter Create Form
 │
 │ title + content + media
 ▼
Django Post API
 │
 ├── PostgreSQL
 │
 └── Cloudinary
       │
       └── uploaded images
 │
 ▼
Created Post
 │
 ▼
Flutter normalized post state
```

---

# Data Flow: Social Interaction

For a post like:

```text
User taps Like
      ↓
Flutter updates UI optimistically
      ↓
Post provider / state updated
      ↓
API request
      ↓
Django validates operation
      ↓
Database updated
      ↓
Client state remains synchronized
```

The same general architecture is used for other interactive operations
where appropriate.

---

# Data Flow: Explore

```text
User preferences
       ↓
Django Explore endpoint
       ↓
Genre-filtered posts
       ↓
Paginated response
       ↓
Flutter post cache
       ↓
Explore UI
       ↓
Upcoming content preloaded
       ↓
Cached images displayed
```

The combination of pagination, normalized state, image caching, and
preloading is intended to keep Explore responsive while browsing
visually heavy content.

---

# Media Storage

Uploaded images are stored on Cloudinary.

The backend stores the relevant Cloudinary URL/reference rather than
depending on the local server filesystem.

```text
Flutter
   │
   |
   ▼
Django
   │
   │ upload
   ▼
Cloudinary
   │
   ▼
Stored media URL
   │
   ▼
Post / User data
```

This makes media storage independent from the application server and is
more suitable for production deployment.

---

# Backend Data Relationships

At a high level, the application's main entities relate as follows:

```text
User
 │
 ├── Posts ──────────── Movie
 │     │
 │     ├── Likes
 │     └── Comments
 │           │
 │           ├── Likes
 │           └── Replies
 │
 ├── Followers / Following
 │
 └── Preferred Genres
```

A post belongs to a user and references a movie/TV record.

Users can interact with posts through likes and comments and interact
socially through follow relationships.

---

# Architectural Goals

The architecture is designed around four main goals:

### Separation of concerns

UI, state, API communication, and persistence have distinct
responsibilities.

### Consistent state

Shared normalized state prevents multiple screens from drifting apart
when interactive data changes.

### Responsive UX

Caching, preloading, pagination, debounced search, and optimistic
interactions reduce unnecessary waiting.

### Production-oriented infrastructure

Persistent application data is stored in the backend database while
uploaded media is handled by Cloudinary rather than the application
server's local filesystem.
