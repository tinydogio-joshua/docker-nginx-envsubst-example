#!/usr/bin/env sh

set -eu

envsubst '$TEST_ENV' < /frontend/index.html > /tmp/index.html.temp && cp -f /tmp/index.html.temp /frontend/index.html

exec "$@"
