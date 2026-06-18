# lema_access_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment Config

Build-time environment values now live in
`lib/src/core/env_config.dart` instead of `.env` files.

Builds should use the normal Flutter CLI directly:

```bash
flutter build ios
flutter build ios --dart-define=APP_ENV=staging
flutter build ios --dart-define=APP_ENV=local
```

`flutter build ios` defaults to `staging`.

`APP_ENV` accepts `local`, `staging`, or `prod`.

For `flutter run`, you can still use the helper script:

```bash
./script/flutter_run.sh
./script/flutter_run.sh staging
```

`./script/flutter_run.sh` defaults to `local`.

## App Icons

The Android and iOS app icons are generated from a single source image at
`assets/branding/app_icon.png`.

To regenerate the launcher icons:

```bash
./script/generate_app_icons.sh
```

To swap in a new source file and regenerate in one step:

```bash
./script/generate_app_icons.sh /absolute/path/to/new-icon.png
```

This updates only the Android and iOS launcher icon assets.
