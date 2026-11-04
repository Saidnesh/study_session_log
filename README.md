# Study Session Log

A Flutter student-life app for logging study sessions, with local SQLite storage.
Built for STTPK2143 App Programming, Assignment 1.

Author: Sai Dhenesh [309772] [Group A]
Demo video: [https://youtu.be/SO3bj95y8U8?si=GNkepItNw29zBJto]

## Purpose
Students record what they studied, for how long, and optional notes, then review
their history in a paginated list.

## Features
- Splash screen, then a home list (10 records per page, newest first)
- Add, view details, edit, and delete study sessions
- Form validation with clear error messages
- Confirmation dialogs before save, update, and delete
- Success and failure feedback after each action
- Refresh button and Previous/Next pagination
- Data stored locally in SQLite, so it persists after restart

## Database (table `study_sessions`)
| Column | Type | Notes |
| --- | --- | --- |
| id | INTEGER | Primary key, autoincrement |
| title | TEXT | Required, 3-60 chars |
| subject | TEXT | Required, from dropdown |
| duration_minutes | INTEGER | Required, 1-720 |
| notes | TEXT | Optional, max 200 chars |
| created_at | TEXT | ISO-8601 timestamp |

## Project structure
```
lib/
  main.dart
  models/study_session.dart
  database/database_helper.dart
  screens/splash_screen.dart, home_screen.dart, session_form_screen.dart
  widgets/pagination_bar.dart
```

## How to run
1. Install Flutter and set up an Android emulator or device
2. `git clone [repo link]`
3. `flutter pub get`
4. `flutter run`

Tested on: [Pixel 6a(Android emulator), Flutter version : 3.47.5]

## Credits
- Packages used: `sqflite` (local SQLite database) and `path` (database file location), both from pub.dev
- Icons: Flutter Material icons
- Flutter
- Codex and Claude
- Youtube
