resource "aws_kinesis_firehose_delivery_stream" "data_analytics" {
  name        = var.firehose_name
  destination = var.destination

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = var.bucket_arn

    buffering_interval = 60
    buffering_size     = 64

    processing_configuration {
      enabled = true

      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = var.lambda_arn
        }
      }
    }

    dynamic_partitioning_configuration {
      enabled = true
    }

    prefix              = "year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/age=!{partitionKeyFromLambda:age}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/!{firehose:error-output-type}/"
  }

  server_side_encryption {
    enabled = true
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kinesis" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.kinesis.arn
}

resource "aws_iam_policy" "kinesis" {
  name   = "kinesis-policy"
  policy = data.aws_iam_policy_document.all_policy.json
}

data "aws_iam_policy_document" "all_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "*"
    ]
  }
}