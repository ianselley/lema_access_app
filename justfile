# Flutter run helpers. Defaults to the connected iPhone; pass an empty first
# argument to let Flutter choose, e.g. `just run-staging '' -d chrome`.
#   just run --release

default:
    @just --list

# Debug run (local Supabase on LAN IP)
run device='-d 00008150-000C70943E40C01C' *args:
    ./script/flutter_run.sh local {{ device }} {{ args }}

run-local device='-d 00008150-000C70943E40C01C' *args:
    ./script/flutter_run.sh local {{ device }} {{ args }}

run-staging device='-d 00008150-000C70943E40C01C' *args:
    ./script/flutter_run.sh staging {{ device }} {{ args }}

run-prod device='-d 00008150-000C70943E40C01C' *args:
    ./script/flutter_run.sh prod {{ device }} {{ args }}

# Release run
run-release device='-d 00008150-000C70943E40C01C' *args:
    ./script/flutter_run.sh local --release {{ device }} {{ args }}

run-staging-release device='-d 00008150-000C70943E40C01C' *args:
    ./script/flutter_run.sh staging --release {{ device }} {{ args }}

run-prod-release device='-d 00008150-000C70943E40C01C' *args:
    ./script/flutter_run.sh prod --release {{ device }} {{ args }}

_ensure-production:
    @grep -A1 -F 'static const String defaultEnvironmentName =' lib/src/core/env_config.dart | grep -Fq "      'prod';" || { echo 'The default app environment must be prod.' >&2; exit 1; }

build-ios: _ensure-production
    flutter build ipa --release --dart-define=APP_ENV=prod

build-android: _ensure-production
    flutter build appbundle --release --dart-define=APP_ENV=prod

show-last-build:
    @test -d build/ios/archive/Runner.xcarchive || { echo 'No iOS archive found. Run `just build` first.' >&2; exit 1; }
    @echo "Android bundle folder: $PWD/build/app/outputs/bundle/release"
    @open -a Xcode "$PWD/build/ios/archive/Runner.xcarchive"

build: _ensure-production
    flutter build ipa --release --dart-define=APP_ENV=prod & ios_pid=$!; flutter build appbundle --release --dart-define=APP_ENV=prod & android_pid=$!; wait $ios_pid; ios_status=$?; wait $android_pid; android_status=$?; test $ios_status -eq 0 -a $android_status -eq 0 && just show-last-build
