#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: run-with-cpu-fraction.sh CPU_FRACTION [--] COMMAND [ARG...]

CPU_FRACTION must be between 0.0 and 1.0.
  0.0 disables taskset and runs the command without CPU pinning.
  1.0 pins the command to all available CPU cores.
EOF
}

if [[ $# -lt 2 ]]; then
    usage >&2
    exit 1
fi

cpu_fraction="$1"
shift

if [[ ${1:-} == "--" ]]; then
    shift
fi

if [[ $# -eq 0 ]]; then
    usage >&2
    exit 1
fi

if ! [[ $cpu_fraction =~ ^(0(\.[0-9]+)?|1(\.0+)?)$ ]]; then
    echo "Error: CPU_FRACTION must be a number between 0.0 and 1.0." >&2
    exit 1
fi

total_cores="$(nproc)"

if [[ $cpu_fraction == "0" || $cpu_fraction == "0.0" || $cpu_fraction == "0.00" ]]; then
    echo "Using ${total_cores}/${total_cores} CPU cores (taskset disabled)."
    exec "$@"
fi

if ! command -v taskset >/dev/null 2>&1; then
    echo "Warning: taskset is not available. Using ${total_cores}/${total_cores} CPU cores without pinning." >&2
    exec "$@"
fi

selected_cores="$(awk -v total="$total_cores" -v fraction="$cpu_fraction" 'BEGIN {
    if (fraction >= 1.0) {
        print total;
        exit 0;
    }

    count = int(total * fraction);
    if (count < 1) {
        count = 1;
    }
    print count;
}')"
last_core=$((selected_cores - 1))

echo "Using ${selected_cores}/${total_cores} CPU cores."
exec taskset --cpu-list "0-${last_core}" "$@"
