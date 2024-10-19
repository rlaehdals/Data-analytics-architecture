module "kinesis-convert" {
  source = "./common"

  lambda_name   = "kinesis-convert"
  variables     = {}
  architectures = ["arm64"]

  image_uri = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/kinesis-convert-lambda:latest"

  common_lambda_policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:firehose:${var.account_id}:${var.account_id}:deliverystream/${var.firehose_name}"]
    actions = [
      "firehose:PutRecord"
    ]
  }
}
