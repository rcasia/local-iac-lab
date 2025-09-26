#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

rm -f function.zip
pip3 install --target ./package boto3 >/dev/null
cd package
zip -r ../function.zip . >/dev/null
cd ..
zip -g function.zip handler.py >/dev/null
echo "Built lambda at $(pwd)/function.zip"
