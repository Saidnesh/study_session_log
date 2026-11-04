# Study Session Log

A Flutter student-life app for logging study sessions, with local SQLite storage.
Built for STTPK2143 Assignment 1.

## Purpose
Students record what they studied, for how long, and optional notes, then review
their history in a paginated list.

## Record fields (table `study_sessions`)
| Column | Type | Notes |
| --- | --- | --- |
| id | INTEGER | Primary key, autoincrement |
| title | TEXT | Required, 3-60 chars |
| subject | TEXT | Required, chosen from dropdown |
| duration_minutes | INTEGER | Required, whole number 1-720 |
| notes | TEXT | Optional, max 200 chars |
| created_at | TEXT | ISO-8601 timestamp, set on insert |

## Main flow
Splash (3 s) -> Home list (10 per page, newest first) -> Add (validate -> confirm -> save)
-> Tap = details dialog -> Edit (validate -> confirm -> update) -> Long-press = delete confirmation
-> Refresh re-queries SQLite -> Previous/Next at the bottom.

## Project structure
```
lib/
  main.dart
  models/study_session.dart
  database/database_helper.dart
  screens/splash_screen.dart, home_screen.dart, session_form_screen.dart
  widgets/pagination_bar.dart
```

## Setup
1. `flutter create study_session_log`
2. Replace its `lib/` folder and `pubspec.yaml` with the ones from this project; delete `test/widget_test.dart`.
3. `flutter pub get`
4. `flutter run` (Android emulator)

## Credits
- Flutter
- Codex and Claude
- Sqflite(Local SQLite database and path database file location)
- Material icons (Flutter)
- Youtube
