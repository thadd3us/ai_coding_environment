#!/bin/env bash
set -euo pipefail

# Check that the notebook directory exists.
if [ ! -d "$1" ]; then
    echo "Notebook directory $1 does not exist."
    exit 1
fi


openvscode-server \
    --without-connection-token \
    --host 0.0.0.0 \
    --default-folder $1
