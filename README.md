# DriveNotes

A Flutter application that allows users to create, edit, and manage notes that are synced with Google Drive.

## Features

- Google OAuth 2.0 authentication
- Create, read, update, and delete notes
- Automatic sync with Google Drive
- Material 3 design
- Dark/light theme support

## Setup

1. Create a Google Cloud Project:

   - Go to the [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project
   - Enable the Google Drive API
   - Configure the OAuth consent screen
   - Create OAuth 2.0 client credentials (Web application type)
   - Add your redirect URI (e.g., `com.example.drivenotes:/oauth2redirect`)

2. Configure the application:

   - Open `lib/features/auth/data/repositories/auth_repository_impl.dart`
   - Replace the `_clientId` and `_clientSecret` constants with your OAuth credentials

3. Install dependencies:

```bash
flutter pub get
```

4. Generate code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. Run the application:

```bash
flutter run
```

## Dependencies

- flutter_riverpod: State management
- dio: HTTP client
- flutter_secure_storage: Secure storage for tokens
- googleapis and googleapis_auth: Google APIs
- go_router: Navigation
- freezed: Immutable models
- json_serializable: JSON serialization

## Project Structure

```
lib/
├── core/
│   ├── router/
│   └── theme/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── notes/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
