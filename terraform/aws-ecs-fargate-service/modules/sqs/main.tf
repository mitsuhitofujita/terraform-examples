
resource "aws_sqs_queue" "deadletter" {
  name                      = "${var.name_prefix}-deadletter-queue"
  max_message_size          = 262144
  message_retention_seconds = 345600
}

resource "aws_sqs_queue" "main" {
  name                       = "${var.name_prefix}-queue"
  visibility_timeout_seconds = 600
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 20
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter.arn
    maxReceiveCount     = 3
  })
}
