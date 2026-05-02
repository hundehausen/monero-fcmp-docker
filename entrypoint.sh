#!/bin/sh
set -e

# Set required --non-interactive flag
set -- "monerod" "--non-interactive" "$@"

# Configure NUMA if present for improved performance
if command -v numactl >/dev/null 2>&1; then
    numa="numactl --interleave=all"
    set -- "$numa" "$@"
fi

# Start the daemon using fixuid
exec fixuid -q "$@"
