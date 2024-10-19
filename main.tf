module "lambda" {
  source = "./lambda"

  account_id    = "" # account id 넣기
  region        = "ap-northeast-2"
  firehose_name = "data-analytics"
}

module "s3" {
  source = "./s3"

  bucket_name = "data-analytics-dkim"
}

module "kinesis-data-firehose" {
  source = "./kinesis-data-firehose"

  firehose_name = "data-analytics"
  destination   = "extended_s3"
  bucket_arn    = module.s3.bucket_arn
  lambda_arn    = module.lambda.lambda_arn
}

module "athena" {
  source = "./athena"

  bucket_id     = module.s3.bucket_id
  database_name = "data_analytics"
}

module "ecr" {
  source = "./ecr"
}