import app
from unittest.mock import Mock, patch

# test response guage and expect 200
def test_pass_response():
    with patch('requests.get') as mock_request:
        url = 'https://httpstat.us/200'
        mock_request.return_value.status_code = 200

        assert app.response_guage(url) == 200

# test response guage and expect 503
def test_fail_response():
    with patch('requests.get') as mock_request:
        url = 'https://httpstat.us/503'
        mock_request.return_value.status_code = 503

        assert app.response_guage(url) == 503