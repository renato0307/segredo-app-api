resource "aws_api_gateway_rest_api" "segredo_app_api" {
  name        = "SegredoAppRestAPI"
  description = "Rest API for the SegredoApp"
}

resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.segredo_app_api.id
   parent_id   = aws_api_gateway_rest_api.segredo_app_api.root_resource_id
   path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.segredo_app_api.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.segredo_app_api.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.segredo_app_api.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
   rest_api_id   = aws_api_gateway_rest_api.segredo_app_api.id
   resource_id   = aws_api_gateway_rest_api.segredo_app_api.root_resource_id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
   rest_api_id = aws_api_gateway_rest_api.segredo_app_api.id
   resource_id = aws_api_gateway_method.proxy_root.resource_id
   http_method = aws_api_gateway_method.proxy_root.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.segredo_app_api.invoke_arn
}

resource "aws_api_gateway_deployment" "segredo_app_api" {
   depends_on = [
     aws_api_gateway_integration.lambda,
     aws_api_gateway_integration.lambda_root,
   ]

   rest_api_id = aws_api_gateway_rest_api.segredo_app_api.id
   stage_name  = "production"
}

output "base_url" {
  value = aws_api_gateway_deployment.segredo_app_api.invoke_url
}