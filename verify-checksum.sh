#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/output"
sha256sum -c sha256.txt
