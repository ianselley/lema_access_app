# lema_access_app

App to scan LEMA tickets.

## Environment Config

Build-time environment values now live in
`lib/src/core/env_config.dart` instead of `.env` files.

Builds should use the normal Flutter CLI directly:

```bash
flutter build ios
flutter build ios --dart-define=APP_ENV=staging
flutter build ios --dart-define=APP_ENV=local
```

`flutter build ios` defaults to `prod`.

`APP_ENV` accepts `local`, `staging`, or `prod`.

### Android Production Build

Build the Android production app bundle from the Android project using Gradle:

```bash
cd android
./gradlew :app:bundleRelease
```

This command does not pass an `APP_ENV` override, so the app uses the default
environment from `lib/src/core/env_config.dart`, which is `prod`.

The generated bundle is written to:

```text
build/app/outputs/bundle/release/app-release.aab
```

This is the preferred command for store builds because it uses the Android
Gradle tooling directly for release packaging, signing, native symbol stripping,
and bundle generation.

### iOS App Store Build

For App Store releases, build the Flutter iOS release first, then create the
archive from Xcode.

Update the version and build number in `pubspec.yaml` before building:

```yaml
version: 1.0.2+4
```

Then regenerate the iOS release build:

```bash
flutter build ios --release --dart-define=APP_ENV=prod
```

Before archiving, confirm Xcode received the current Flutter version values:

```bash
rg "FLUTTER_BUILD_NAME|FLUTTER_BUILD_NUMBER" ios/Flutter/Generated.xcconfig
```

The output should match the `pubspec.yaml` version. For `version: 1.0.2+4`,
it should show:

```text
FLUTTER_BUILD_NAME=1.0.2
FLUTTER_BUILD_NUMBER=4
```

Open the iOS workspace:

```bash
open ios/Runner.xcworkspace
```

In Xcode:

1. Select the `Runner` scheme.
2. Select `Any iOS Device (arm64)` as the destination.
3. Run `Product` -> `Archive`.
4. In Organizer, select the new archive.
5. Click `Distribute App` -> `App Store Connect` -> `Upload`.

If Organizer shows an older version or build number, close Xcode and rerun the
Flutter build step above. Xcode archives using the generated values in
`ios/Flutter/Generated.xcconfig`, so stale generated files can produce an
archive with the previous version.

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
