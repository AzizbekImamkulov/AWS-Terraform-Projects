data "aws_caller_identity" "current" {}

resource "aws_iot_thing" "device" {
  name = "${var.project_name}-${var.environment}-device"
}

resource "aws_iot_policy" "iot_policy" {
  name = "${var.project_name}_iot_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : ["iot:Connect", "iot:Publish", "iot:Receive", "iot:Subscribe"],
      "Resource" : "*"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "${var.project_name}_lambda_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Scan"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.device_data.arn
      }
    ]
  })
}


resource "aws_iot_certificate" "cert" {
  active = true
}

resource "aws_iot_thing_principal_attachment" "attach_cert" {
  thing     = aws_iot_thing.device.name
  principal = aws_iot_certificate.cert.arn
}

resource "aws_iot_topic_rule" "iot_to_lambda" {
  name    = "${var.project_name}_${var.environment}_rule"
  enabled = true

  sql         = "SELECT * FROM 'smartedge-dev-device/data'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.processor.arn
  }

  depends_on = [aws_lambda_permission.allow_iot]
}


resource "aws_dynamodb_table" "device_data" {
  name         = "${var.project_name}-${var.environment}-device-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "device_id"
  range_key    = "timestamp"

  attribute {
    name = "device_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}_lambda_role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Action : "sts:AssumeRole",
      Effect : "Allow",
      Principal : { Service : "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_lambda_function" "processor" {
  function_name = "${var.project_name}_iot_processor"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "${path.module}/../../lambda/iot_processor.zip"
  handler       = "main.handler"
  runtime       = "python3.9"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.device_data.name
    }
  }
}

resource "aws_lambda_permission" "allow_iot" {
  statement_id  = "AllowExecutionFromIoT"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "iot.amazonaws.com"
  source_arn    = "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:rule/${var.project_name}_${var.environment}_rule"
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.processor.invoke_arn
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /data"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
