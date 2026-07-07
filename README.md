
# MovieA

A native iOS movie discovery app built with SwiftUI. Users sign in, browse and search movies, view details, save favorites, and leave star ratings and reviews.

## Screens

- **Sign In** — authenticates against a real backend (Airtable `users` table)
- **Movies Center** — High Rated carousel, genre rows (Drama, Comedy), and search
- **Movie Details** — poster, story, cast & director, duration/genre/age, ratings and reviews
- **Profile** — user info, saved movies, edit name/avatar

## Features

- Real authentication (email/password checked against the backend, no mock login)
- Browse movies by category with live search
- Save/bookmark movies to a personal collection
- Share a movie via the system share sheet
- Rate and review movies with a star picker; newest review shown first
- Edit profile name and avatar, synced across the app and persisted locally

## Architecture

MVVM, with a clear separation between layers:

```
MovieA/
├── Model/        # Data models, decoding, and persisted stores (saved movies, current user, profile)
├── Networking/   # API client and services (Airtable REST API)
├── View/         # SwiftUI screens and reusable components
└── ViewModels/   # Per-screen view models (business logic, no UI)
```

## Tech Stack

- **UI:** SwiftUI
- **Concurrency:** Swift async/await
- **Backend:** [Airtable](https://airtable.com) REST API (`movies`, `actors`, `directors`, `reviews`, `users` tables)
- **Persistence:** UserDefaults (saved movies, profile, session)

## Setup

1. Open `MovieA.xcodeproj` in Xcode.
2. Create an Airtable Personal Access Token (scopes: `data.records:read`, `data.records:write`) with access to the project's base, and add it to `MovieA/Secrets.xcconfig`:
   ```
   API_TOKEN = your_token_here
   ```
3. Build and run on any iOS simulator (iOS 17+).
