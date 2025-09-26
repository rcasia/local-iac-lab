locals {
  name_prefix = var.project
}

# S3 bucket
resource "aws_s3_bucket" "data" {
  bucket = "${local.name_prefix}-data"
}

# DynamoDB table
resource "aws_dynamodb_table" "events" {
  name         = "${local.name_prefix}-events"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# SQS queue
resource "aws_sqs_queue" "inbox" {
  name = "${local.name_prefix}-inbox"
}

# ---- FIX: single IAM role with inline assume-role policy ----
resource "aws_iam_role" "lambda_role" {
  name = "${local.name_prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Minimal inline policy for DynamoDB + logs + SQS (for event source mapping)
data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.events.arn]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  # Needed for Lambda to poll SQS when using an event source mapping
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [aws_sqs_queue.inbox.arn]
  }
}

resource "aws_iam_role_policy" "lambda_inline" {
  name   = "${local.name_prefix}-lambda-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

# Package the Lambda (zip built by build.sh)
resource "aws_lambda_function" "consumer" {
  function_name    = "${local.name_prefix}-consumer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.handler"
  runtime          = "python3.11"
  filename         = "${path.module}/lambda/function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.events.name
    }
  }
}

# Event source mapping SQS -> Lambda
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.inbox.arn
  function_name    = aws_lambda_function.consumer.arn
  batch_size       = 1
  enabled          = true
}
