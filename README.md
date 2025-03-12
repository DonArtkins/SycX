# SycX Flutter App

SycX is an AI-powered summarization app designed to help university students simplify complex academic content. This Flutter application serves as the front-end for the SycX platform.

## Table of Contents

1. [Features](#features)
2. [Getting Started](#getting-started)
   - [Prerequisites](#prerequisites)
   - [Installation](#installation)
3. [Project Structure](#project-structure)
4. [Usage](#usage)
5. [Testing](#testing)
6. [Building for Production](#building-for-production)
7. [Contributing](#contributing)
8. [License](#license)

## Features

- Document upload and management
- AI-powered text summarization
- Visual aids generation
- User feedback system
- Cross-platform compatibility (iOS and Android)

## Getting Started

### Prerequisites

- Flutter SDK (version 2.5.0 or later)
- Dart (version 2.14.0 or later)
- Android Studio or VS Code with Flutter extensions
- iOS development tools (for Mac users)

### Installation

1. Navigate to the project directory:
   ```
   cd sycx_flutter_app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart
├── config/
├── models/
├── screens/
├── services/
├── utils/
└── widgets/
```

- `main.dart`: The entry point of the application
- `config/`: Configuration files and constants
- `models/`: Data models and classes
- `screens/`: Main app screens and pages
- `services/`: API services and business logic
- `utils/`: Utility functions and helpers
- `widgets/`: Reusable UI components

## Usage

1. Launch the app on your device or emulator.
2. Sign in or create a new account.
3. Upload a document you want to summarize.
4. Wait for the AI to process and generate a summary.
5. View the summary along with any generated visual aids.
6. Provide feedback to help improve the summarization quality.

## Testing

To run the tests for the SycX Flutter app:

```
flutter test
```

## Building for Production

To build the app for production:

For Android:
```
flutter build apk --release
```

For iOS:
```
flutter build ios --release
```

## Contributing

We welcome contributions to the SycX Flutter app! Please read our [Contributing Guidelines](../CONTRIBUTING) for more information on how to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.
