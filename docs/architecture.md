Flutter
│
│ REST / JWT
▼
Django REST Framework
│
├── PostgreSQL
├── TMDB
└── Cloudinary (later)

accounts → users/auth
movies → TMDB + Movie
posts → posts/comments/likes
social → follows/suggestions

Django/PostgreSQL is the source of truth. TMDB provides movie metadata, but movies actually used by the application are cached in our database.
