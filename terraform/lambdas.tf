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

resource "aws_lambda_function" "segredo_app_api" {
  function_name = "SegredoAppAPI"

  s3_bucket = aws_s3_bucket.s3-segredo-app-api-code.id
  s3_key    = "segredo-app-api.zip"

  handler = "handler.handler"
  runtime = "python3.8"

  role = aws_iam_role.segredo_app_api_exec.arn

  depends_on = [null_resource.build_and_upload_code_to_s3]
}

resource "aws_iam_role" "segredo_app_api_exec" {
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

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.segredo_app_api.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.segredo_app_api.execution_arn}/*/*"
}