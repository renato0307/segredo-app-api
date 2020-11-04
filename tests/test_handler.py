"""
Tests for lambda handler supporting the segredo-app-api
"""
import os

import boto3
import handler
import moto
from botocore.exceptions import ClientError


def test_missing_resource():
    result = handler.handler({}, None)

    assert result.get("statusCode") == 400


def test_invalid_resource():
    result = handler.handler({"resource": "/somethingnotvalud"}, None)

    assert result.get("statusCode") == 400


def test_invalid_path():
    event = {"resource": "/{proxy+}", "path": "/invalidpath"}
    result = handler.handler(event, None)

    assert result.get("statusCode") == 501


def test_put_is_invalid_method():
    event = {"resource": "/{proxy+}", "path": "/secret", "httpMethod": "PUT"}
    result = handler.handler(event, None)

    assert result.get("statusCode") == 501


def test_delete_is_invalid_method():
    event = {"resource": "/{proxy+}", "path": "/secret", "httpMethod": "DELETE"}
    result = handler.handler(event, None)

    assert result.get("statusCode") == 501


@moto.mock_dynamodb2
def test_create_secret():

    # arranje
    region = "us-east-1"
    os.environ[handler.ENV_DYNAMO_DB_REGION] = region

    table_name = "Secrets"
    dynamodb = boto3.resource("dynamodb", region)
    table = dynamodb.create_table(
        TableName=table_name,
        KeySchema=[
            {"AttributeName": "SecretId", "KeyType": "HASH"},
        ],
        AttributeDefinitions=[
            {"AttributeName": "SecretId", "AttributeType": "S"},
        ],
    )

    content = "SECRET CONTENT"
    event = {
        "resource": "/{proxy+}",
        "path": "/secret",
        "httpMethod": "POST",
        "body": content,
    }

    # act
    result = handler.handler(event, None)

    # assert
    assert result.get("statusCode") == 200
    assert result.get("body").get("SecretId")

    secret_id = result.get("body").get("SecretId")
    response = table.get_item(Key={"SecretId": secret_id})
    assert "Item" in response

    item = response["Item"]
    assert item.get("SecretContent") == content


def test_boto3_error_occurs_on_create_secret(mocker):

    # arranje
    region = "us-east-1"
    os.environ[handler.ENV_DYNAMO_DB_REGION] = region

    event = {
        "resource": "/{proxy+}",
        "path": "/secret",
        "httpMethod": "POST",
    }

    mock = mocker.patch("handler._get_dynamodb_client")
    mock.side_effect = ClientError({}, "SomeOperation")

    # act
    result = handler.handler(event, None)

    # assert
    assert result.get("statusCode") == 500
