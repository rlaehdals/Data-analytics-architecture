locals {
  commons = {
    "common" = "common"
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_name
  architectures = var.architectures

  memory_size  = var.memory_size
  package_type = "Image"
  image_uri    = var.image_uri
  timeout      = var.timeout

  environment {
    variables = merge(var.variables, local.commons)
  }

  vpc_config {
    security_group_ids = []
    subnet_ids         = []
  }

  role = aws_iam_role.iam_for_lambda.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.lambda_name}_assume_role"
  assume_role_policy = data.aws_iam_policy_document.iam_for_lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_iam" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.lambda_name}_policy"
  policy = data.aws_iam_policy_document.common_lambda_policy.json
}

data "aws_iam_policy_document" "common_lambda_policy" {
  override_policy_documents = [var.common_lambda_policy]
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]
  }
  statement {
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}


data "aws_iam_policy_document" "iam_for_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}
