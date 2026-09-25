#!/bin/sh
# Healthcheck for monerod that supports --rpc-login.
# The RPC port and credentials are read from the running daemon's command
# line (PID 1), so the check follows the container's configuration.
# Adapted from sethforprivacy/simple-monerod-docker. The fallback port is
# the testnet RPC default, which this stressnet image uses.
set -eu

# Print the value of a daemon argument, handling both "--flag=value" and
# "--flag value" forms. Prints nothing if the flag is absent.
get_arg() {
    tr '\0' '\n' < /proc/1/cmdline | awk -v flag="$1" '
        prev == flag { print; exit }
        index($0, flag "=") == 1 { print substr($0, length(flag) + 2); exit }
        { prev = $0 }
    '
}

RPC_LOGIN="$(get_arg --rpc-login)"
# Prefer the restricted RPC port, then the full RPC port. monerod listens
# on 127.0.0.1:28081 by default under --testnet.
RPC_PORT="$(get_arg --rpc-restricted-bind-port)"
[ -n "${RPC_PORT}" ] || RPC_PORT="$(get_arg --rpc-bind-port)"
RPC_URL="http://127.0.0.1:${RPC_PORT:-28081}/get_height"

if [ -n "${RPC_LOGIN}" ]; then
    curl --fail --silent --digest --user "${RPC_LOGIN}" "${RPC_URL}"
else
    # Credentials may still be set via --config-file, which cannot be read
    # here; a 401 response proves the RPC server is alive regardless.
    status="$(curl --silent --output /dev/null --write-out '%{http_code}' "${RPC_URL}")"
    [ "${status}" = "200" ] || [ "${status}" = "401" ]
fi
