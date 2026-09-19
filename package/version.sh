#!/usr/bin/env bash
# Print which Verilator this is, and fail if it cannot say.
set -o errexit -o nounset -o pipefail
"$1" --version
