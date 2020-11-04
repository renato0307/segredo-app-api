"""
Lambda handler supporting the segredo-app-api
"""
import datetime
import logging
import os
import random
import string

import boto3
from botocore.exceptions import ClientError

RESOURCE = "/{proxy+}"
PATH = "/secret"

ENV_DYNAMO_DB_REGION = "DYNAMO_DB_REGION"


def handler(event, context):
    if event.get("resource") != RESOURCE:
        return _invalid_request()

    path = event.get("path")
    if path != PATH:
        return _invalid_path(path)

    method = event.get("httpMethod")
    if method == "POST":
        return _create_secret(event)

    if method == "GET":
        return _get_secret(event)

    return _invalid_method(method)


def _invalid_path(path):
    return {"statusCode": 501, "body": f"Resource not supported: {path}"}


def _invalid_request():
    return {"statusCode": 400, "body": "Invalid request"}


def _invalid_method(method):
    return {"statusCode": 501, "body": f"Method not supported: {method}"}


def _unexpected_error():
    return {"statusCode": 500, "body": "Unexcepted error"}


def _create_secret(event):
    try:
        dynamodb = _get_dynamodb_client()
        table = dynamodb.Table("Secrets")

        random_id = _get_random_alphanumeric_string()
        table.put_item(
            Item={
                "SecretId": random_id,
                "SecretContent": event.get("body"),
                "TimeToExist": int(datetime.datetime.utcnow().timestamp()),
            }
        )

        return {"statusCode": 200, "body": {"SecretId": random_id}}
    except ClientError as e:
        logging.error("error creating secret: %s" % e)
        return _unexpected_error()


def _get_dynamodb_client():
    return boto3.resource("dynamodb", region_name=_get_region())


def _get_secret(event):
    return {"statusCode": 200, "body": "Secret retrieved"}


def _get_random_alphanumeric_string():
    letters_and_digits = string.ascii_letters + string.digits
    result_str = "".join((random.choice(letters_and_digits) for i in range(80)))

    return result_str


def _get_region():
    return os.getenv(ENV_DYNAMO_DB_REGION)
