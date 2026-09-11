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
