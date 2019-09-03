#!/usr/bin/dumb-init /bin/sh
set -e
exec su-exec pmchs:pmchs runghc /pmchs/main.hs
