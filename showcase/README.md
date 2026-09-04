# Showcase — Mishmish interactive tour

React + Vite site that maps every Flutter screen and API endpoint. Open locally or deploy statically.

## Run

```bash
npm install
npm run dev    # http://localhost:5173
npm run build  # → dist/
npm run preview
```

## What's inside

- `index.html` + `src/` — single-page tour (Arabic), lists `lib/*.dart` files, API table, and Theme/RTL notes.
- Data driven from the real repo: file paths + line counts in `index.html`'s `FILES` and `ENDPOINTS` arrays — keep them in sync after renames.

## Deploy

`dist/` is static — host on GitHub Pages / Vercel / Netlify, or open `index.html` directly.

See root [`../README.md`](../README.md) and [`../plan.md`](../plan.md).
