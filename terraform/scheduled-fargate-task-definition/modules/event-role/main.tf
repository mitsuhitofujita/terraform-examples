data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudwatch_events_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_events_role_run_task_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task-definition/${var.task_definition_family}:*"]

    condition {
      test     = "StringLike"
      variable = "ecs:cluster"
      values   = [var.cluster_arn]
    }
  }
}

resource "aws_iam_role" "cloudwatch_events_role" {
  name               = "${var.name_prefix}-events-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_events_role_assume_policy.json
}

resource "aws_iam_role_policy" "cloudwatch_events_role_run_task" {
  name   = "${var.name_prefix}-events-role-run-task"
  role   = aws_iam_role.cloudwatch_events_role.id
  policy = data.aws_iam_policy_document.cloudwatch_events_role_run_task_policy.json
}

data "aws_iam_policy_document" "cloudwatch_events_role_pass_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["iam:PassRole"]

    resources = [
      var.task_execution_role_arn,
      var.task_role_arn,
    ]
  }
}

resource "aws_iam_role_policy" "cloudwatch_events_role_pass_role" {
  name   = "${var.name_prefix}-events-ecs-pass-role"
  role   = aws_iam_role.cloudwatch_events_role.id
  policy = data.aws_iam_policy_document.cloudwatch_events_role_pass_role_policy.json
}

