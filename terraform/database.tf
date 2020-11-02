resource "aws_dynamodb_table" "secrets-table" {
  name           = "Secrets"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "SecretId"

  attribute {
    name = "SecretId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

}