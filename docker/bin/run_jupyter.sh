#!/bin/env bash
set -euo pipefail

# Check that the notebook directory exists.
if [ ! -d "$1" ]; then
    echo "Notebook directory $1 does not exist."
    exit 1
fi

jupyter notebook --port 8888 --ip 0.0.0.0 --no-browser --notebook-dir $1
