import requests


def test_basic_request():
    r = requests.get(' https://btlsdk0ef2.execute-api.eu-west-1.amazonaws.com/production/secret')
    assert r.status_code == 200
