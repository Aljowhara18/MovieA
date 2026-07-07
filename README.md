# MovieA

An iOS app for browsing movies, viewing details, and leaving ratings/reviews. Built with SwiftUI.

## Features

- Sign in with a real account (checked against an Airtable backend)
- Browse movies by category (High Rated, Drama, Comedy) with search
- Movie details: poster, story, cast & director, duration, genre, age rating
- Save/bookmark movies to your profile
- Share a movie
- Rate and review movies (star picker, newest reviews shown first)
- Edit profile (name, avatar) with local persistence

## Tech Stack

- SwiftUI, Swift Concurrency (async/await)
- MVVM architecture (View / ViewModel / Model)
- [Airtable](https://airtable.com) REST API as the backend (movies, actors, directors, reviews, users tables)
- UserDefaults for local persistence (saved movies, profile, session)

## Project Structure

```
MovieA/
├── Model/          # Data models + Airtable-backed stores
├── Networking/      # API client and services
├── View/            # SwiftUI screens and components
├── ViewModels/       # Per-screen view models
```

## Setup

1. Open `MovieA.xcodeproj` in Xcode.
2. Add your own Airtable Personal Access Token to `MovieA/Secrets.xcconfig`.
3. Build and run on any iOS simulator.
