# API Documentation

## Endpoint Summary

| Method      | Endpoint                           | Purpose             |
| ----------- | ---------------------------------- | ------------------- |
| POST        | `/api/auth/register/`              | Register            |
| POST        | `/api/auth/login/`                 | Login               |
| POST        | `/api/auth/refresh/`               | Refresh JWT         |
| GET         | `/api/auth/me/`                    | Current user        |
| GET         | `/api/movies/search/`              | TMDB search         |
| GET         | `/api/movies/:id/`                 | Movie/TV details    |
| GET         | `/api/movies/genres/`              | List genres         |
| GET         | `/api/posts/`                      | Home feed           |
| POST        | `/api/posts/create/`               | Create post         |
| POST/DELETE | `/api/posts/:id/like/`             | Like/unlike post    |
| GET/POST    | `/api/posts/:id/comments/`         | Comments            |
| POST/DELETE | `/api/posts/comments/:id/like/`    | Like/unlike comment |
| POST        | `/api/posts/comments/:id/replies/` | Reply to comment    |
| GET         | `/api/users/suggestions/`          | Follow suggestions  |
| POST/DELETE | `/api/users/:id/follow/`           | Follow/unfollow     |
| GET         | `/api/posts/explore/`              | Explore feed        |
| GET         | `/api/posts/movies/:id/posts/`     | Same-movie posts    |
| GET         | `/api/search/?query=...`           | Search users/posts  |

---

Base URL:

```text
/api/
```

Authentication uses access and refresh tokens.

## Authentication

### Register

```http
POST /api/auth/register/
```

Creates a new user account.

The registration flow also collects the user's preferred movie/TV
genres.

### Login

```http
POST /api/auth/login/
```

Authenticates a user and returns authentication tokens.

### Refresh Token

```http
POST /api/auth/refresh/
```

Refreshes an expired access token.

### Current User

```http
GET /api/auth/me/
```

Returns the authenticated user's information.

### User Detail

```http
GET /api/auth/users/{id}/
```

Returns a user's profile and social information.

### Update Profile

```http
PATCH /api/auth/profile/update/
```

Updates the authenticated user's profile information.

---

## Search

### Search Users and Posts

```http
GET /api/search/?query={query}
```

Searches the application's social content.

The response contains user and post results and supports independent
pagination for the two result types.

---

## Movies

Movie and TV metadata is provided through TMDB and persisted locally in
the application's movie model.

### Search Movies / TV Shows

```http
GET /api/movies/search/
```

Searches TMDB for movies or TV shows.

The media type is supplied as part of the request parameters.

### Movie / TV Detail

```http
GET /api/movies/{tmdb_id}/
```

Returns the application's stored movie/TV record corresponding to a TMDB
ID.

### Genres

```http
GET /api/movies/genres/
```

Returns the available movie/TV genres used by the application.

---

## Posts

### List Posts

```http
GET /api/posts/
```

Returns the authenticated user's feed with pagination.

### Create Post

```http
POST /api/posts/create/
```

Creates a post associated with a movie or TV show.

Post creation can include uploaded media.

Uploaded images are stored using **Cloudinary**, rather than relying on
the application's local filesystem.

### Explore

```http
GET /api/posts/explore/
```

Returns posts used by the Explore experience.

Explore results are filtered according to the user's preferred genres.

### Posts for a Movie

```http
GET /api/posts/movies/{movie_id}/posts/
```

Returns posts associated with a specific movie/TV entry.

This supports browsing additional community posts about the same title.

### Like / Unlike Post

```http
POST /api/posts/{post_id}/like/
```

Toggles the authenticated user's like on a post.

### Comments

```http
GET /api/posts/{post_id}/comments/
POST /api/posts/{post_id}/comments/
```

Retrieves or creates comments for a post.

### Like / Unlike Comment

```http
POST /api/posts/comments/{comment_id}/like/
```

Toggles the authenticated user's like on a comment.

### Replies

```http
GET /api/posts/comments/{comment_id}/replies/
POST /api/posts/comments/{comment_id}/replies/
```

Retrieves or creates replies for a comment.

---

## Social

### User Suggestions

```http
GET /api/users/suggestions/
```

Returns suggested users based on shared interests such as preferred
genres.

### Follow / Unfollow

```http
POST /api/users/{user_id}/follow/
```

Toggles the authenticated user's follow relationship with another user.

---

## Notes

Most authenticated endpoints require the user's access token.

Pagination is used for feed, Explore, and search-related collections
where appropriate.

The exact request and response payloads are defined by the Django REST
Framework serializers and may evolve independently of this high-level
endpoint reference.
