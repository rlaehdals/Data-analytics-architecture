resource "aws_athena_database" "data-analytics" {
  name   = var.database_name
  bucket = var.bucket_id
}