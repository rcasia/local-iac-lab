#!/usr/bin/env bash
set -euo pipefail
export AWS_PAGER=""

TABLE="events"
REGION="${REGION:-eu-west-1}"
USE_LOCAL="${USE_LOCAL:-false}"

ENDPOINT_ARGS=()
if [ "$USE_LOCAL" = "true" ]; then
  ENDPOINT_ARGS+=(--endpoint-url http://localhost:4566)
fi

echo "🧪 Smoke test (USE_LOCAL=$USE_LOCAL) sobre tabla '$TABLE'"

aws dynamodb describe-table \
  --table-name "$TABLE" --region "$REGION" "${ENDPOINT_ARGS[@]}"

aws dynamodb put-item \
  --table-name "$TABLE" --region "$REGION" "${ENDPOINT_ARGS[@]}" \
  --item '{"id":{"S":"1"}, "smoke":{"S":"ok"}}'

aws dynamodb get-item \
  --table-name "$TABLE" --region "$REGION" "${ENDPOINT_ARGS[@]}" \
  --key '{"id":{"S":"1"}}'

echo "✅ Smoke test passed"
