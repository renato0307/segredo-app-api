resource "aws_s3_bucket" "s3-segredo-app-api-code" {
  bucket = "segredo-app-api-code"
  acl = "private"
  versioning { 
    enabled = true
  }
}

resource "null_resource" "build_and_upload_code_to_s3" {
  provisioner "local-exec" {
    command = "cd ${path.module}/.. && ./build.sh && aws s3 cp ./build/segredo-app-api.zip s3://${aws_s3_bucket.s3-segredo-app-api-code.id}"
  }
}

resource "aws_lambda_function" "segredo_app_api_lambda" {
  function_name = "SegredoAppAPI"

  s3_bucket = aws_s3_bucket.s3-segredo-app-api-code.id
  s3_key    = "segredo-app-api.zip"

  handler = "handler.handler"
  runtime = "python3.8"

  role = aws_iam_role.segredo_app_api_lambda_exec.arn

  depends_on = [null_resource.build_and_upload_code_to_s3]
}

resource "aws_iam_role" "segredo_app_api_lambda_exec" {
  name = "SegredoAppAPILambdaExecRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

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