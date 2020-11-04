import handler


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
