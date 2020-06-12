import app

# test response guage and expect 200
def test_pass_response():
    assert app.response_guage('https://httpstat.us/200') == 200

# test response guage and expect 503
def test_fail_response():
    assert app.response_guage('https://httpstat.us/503') == 503