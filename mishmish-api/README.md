# 🐱 Mishmish — Laravel API (مشمش)

REST backend for the Flutter app. Part of [`final_projectV2`](../README.md).

## Stack

- Laravel 13, PHP 8.5, Composer
- Sanctum (Bearer tokens, `auth:sanctum`)
- SQLite by default (`database/database.sqlite`) — swap to MySQL via `.env`
- 6 migrations, 2 seeders (`KittenSeeder` → 12 Arabic kittens, `cataas.com` images)

## Endpoints (`routes/api.php:1`)

| Method | Endpoint | Auth | Body / Returns |
|--------|----------|------|----------------|
| POST | `/api/register` | public | `{name,email,password,password_confirmation}` → 201 + `{token,user}` |
| POST | `/api/login` | public | `{email,password}` → `{token,user}` |
| POST | `/api/logout` | Bearer | — |
| POST | `/api/forgot-password` | public | `{email}` → `{code}` (returned for demo) |
| POST | `/api/verify-code` | public | `{email,code}` |
| POST | `/api/reset-password` | public | `{email,password,password_confirmation}` |
| GET | `/api/kittens` | public | `Kitten[]` |
| GET | `/api/kittens/{id}` | public | `Kitten` |
| GET | `/api/favorites` | Bearer | `Kitten[]` |
| POST | `/api/favorites/{kittenId}` | Bearer | `{is_favorite}` |

## DB schema

```sql
users(id, name, email, password, created_at)
kittens(id, name, breed, age, description, price, image_url, created_at)
favorites(id, user_id, kitten_id, created_at)
password_reset_tokens(email, token, created_at)
```

## Setup

```bash
composer install
cp .env.example .env   # .env already ships with DB_CONNECTION=sqlite
php artisan key:generate
php artisan migrate --seed   # or migrate:fresh --seed to reset
php artisan serve --host=0.0.0.0 --port=8000
# → http://127.0.0.1:8000 and http://<LAN_IP>:8000 (for phones)
```

Verify:

```bash
curl http://127.0.0.1:8000/api/kittens | head -c 400
php artisan test
```

## Config notes

- **CORS** (`config/cors.php:1`): `paths: api/*`, `allowed_origins: *`, `allowed_headers: *`, `supports_credentials: false`. Tighten for production.
- **SQLite** is zero-config. For MySQL, set in `.env`:
  ```
  DB_CONNECTION=mysql
  DB_HOST=127.0.0.1
  DB_PORT=3306
  DB_DATABASE=mishmish
  DB_USERNAME=root
  DB_PASSWORD=
  ```
  then `php artisan migrate --seed`.
- Logs: `storage/logs/laravel.log`; CORS middleware is in Laravel's default global stack (`Illuminate\Http\Middleware\HandleCors`).

## Related

- Flutter app: [`../mishmish/README.md`](../mishmish/README.md)
- Showcase: [`../showcase/README.md`](../showcase/README.md)
- Controllers: `app/Http/Controllers/Api/`
