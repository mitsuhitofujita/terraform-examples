data "aws_iam_policy_document" "role_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:*",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:*",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:*",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "task" {
  name               = "${var.name_prefix}-task-role"
  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_policy" "task" {
  name   = "${var.name_prefix}-task-role-policy"
  policy = data.aws_iam_policy_document.role_policy.json
}

resource "aws_iam_role_policy_attachment" "task" {
  policy_arn = aws_iam_policy.task.arn
  role       = aws_iam_role.task.id
}
