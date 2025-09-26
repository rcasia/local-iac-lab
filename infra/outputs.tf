output "bucket" { value = aws_s3_bucket.data.id }
output "queue" { value = aws_sqs_queue.inbox.id }
output "table" { value = aws_dynamodb_table.events.id }
output "function" { value = aws_lambda_function.consumer.function_name }
