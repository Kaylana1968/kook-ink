from test.test_main import client, fake_user
from common import utils

fake_post = {"description": "Gateau au Chocolat"}


def test_upload_post_ok_when_everything_ok():
    token = utils.generate_token(fake_user)
    headers = {"Authorization": f"Bearer {token}"}

    response = client.post("/post", json=fake_post, headers=headers)

    assert response.status_code == 200


def test_upload_post_not_ok_when_no_headers_passed():
    response = client.post("/post", json=fake_post)

    assert response.status_code == 401
