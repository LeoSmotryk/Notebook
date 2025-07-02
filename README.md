# Notebook

A cross-platform electronic notebook app built with Flutter.

## Features

- Create, view, edit, and delete notes
- Search notes by title or tag
- Filter notes by date
- Local data storage (notes are saved in `notes.json`)
- Ukrainian localization

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (included with Flutter)
- For Windows: Visual Studio with Desktop development tools

### Running the App

#### Windows

1. Open a terminal in the `notebook` directory.
2. Run:
   ```sh
   flutter pub get
   flutter run -d windows
   ```

#### Web

1. Run:
   ```sh
   flutter pub get
   flutter run -d chrome
   ```

#### Other Platforms

- The app supports Linux, macOS, Android, and iOS. Use `flutter run -d <platform>` as appropriate.

## Project Structure

- `lib/main.dart` — Main Flutter app logic and UI
- `notes.json` — Local storage for notes (created at runtime)
- `windows/` — Windows desktop runner (C++ code)
- `web/` — Web assets and manifest

## Usage

- Add a note: Fill in the fields on the right and click "Додати".
- Edit or delete a note: Select a note from the list, then use the buttons.
- Search: Use the search box to filter notes by title or tag.
- Filter by date: Click the calendar icon and select a date.
- Reset app: Go to settings (gear icon) and choose "Скинути додаток".

## License

This project is for educational purposes.

---

For more information on Flutter, see the [official documentation](https://flutter.dev/).
