# Jaidem

A Flutter application built with jaidem.

## Features





- ✅ Material Design 3 Theme
- ✅ Google Fonts Integration
- ✅ Custom Colors & Typography
- ✅ Reusable UI Components

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```



4. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/
│   ├── data/                 # Dependency injection
│   ├── network/              # Network layer
│   ├── routes/               # Navigation setup
│   ├── style/                # Theme and colors
│   ├── utils/                # Constants and helpers
│   └── widgets/              # Reusable components
├── features/
│   └── ...                   # Feature-based architecture
└── main.dart                 # Application entry point
```

## Theme Configuration

The app uses Material Design 3 with custom colors:

- **Primary**: #3C2A98
- **Secondary**: #FF854A
- **Font**: Inter

You can customize these values in `lib/core/style/app_colors.dart` and `lib/core/style/app_text_theme.dart`.

## Dependencies

### Core Dependencies
- `flutter`




- `google_fonts`: Font integration

### Development Dependencies
- `flutter_test`


## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.
