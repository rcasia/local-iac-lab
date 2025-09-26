#!/usr/bin/env bash
set -euo pipefail

endpoint="http://localhost:4566"
queue_url=$(aws --endpoint-url $endpoint sqs get-queue-url --queue-name local-iac-lab-inbox --query 'QueueUrl' --output text)

# Send a message
aws --endpoint-url $endpoint sqs send-message \
  --queue-url "$queue_url" \
  --message-body '{"hello":"world"}' >/dev/null

# Give Lambda a moment to process
sleep 2

# Check DynamoDB has at least one item
count=$(aws --endpoint-url $endpoint dynamodb scan \
  --table-name local-iac-lab-events \
  --select COUNT --query 'Count' --output text)

echo "DynamoDB item count: $count"
test "$count" -ge 1
echo "✅ Smoke test passed"
