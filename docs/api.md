| Method      | Endpoint                           | Purpose            |
| ----------- | ---------------------------------- | ------------------ |
| POST        | `/api/auth/register/`              | Register           |
| POST        | `/api/auth/login/`                 | Login              |
| POST        | `/api/auth/refresh/`               | Refresh JWT        |
| GET         | `/api/auth/me/`                    | Current user       |
| GET         | `/api/movies/search/`              | TMDB search        |
| GET         | `/api/movies/:id/`                 | Movie details      |
| GET         | `/api/posts/`                      | Home feed          |
| POST        | `/api/posts/create/`               | Create post        |
| POST/DELETE | `/api/posts/:id/like/`             | Like/unlike        |
| GET/POST    | `/api/posts/:id/comments/`         | Comments           |
| POST/DELETE | `/api/posts/comments/:id/like/`    | Comment like       |
| POST        | `/api/posts/comments/:id/replies/` | Reply              |
| GET         | `/api/users/suggestions/`          | Follow suggestions |
| POST/DELETE | `/api/users/:id/follow/`           | Follow/unfollow    |
| GET         | `/api/posts/explore/`              | Explore feed       |
| GET         | `/api/posts/movies/:id/posts/`     | Same-movie posts   |
