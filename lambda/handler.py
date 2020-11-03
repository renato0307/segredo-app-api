"""
"""


def handler(event, context):
    if event.get("resource") != "/{proxy+}":
        return _invalid_request()

    path = event.get("path")
    if path != "/secret":
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


def _create_secret(event):
    return {"statusCode": 200, "body": "Secret created"}


def _get_secret(event):
    return {"statusCode": 200, "body": "Secret retrieved"}
