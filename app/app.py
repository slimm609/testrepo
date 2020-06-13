from prometheus_client import start_http_server, Summary, Gauge
import sys
import signal
import requests
import time

urls = ['https://httpstat.us/200', 'https://httpstat.us/503']

print("Starting Metrics server")
# Create a metric to track time spent and requests made.
GAUGE_UP = Gauge('sample_external_url_up', 'HTTP up or down (200 or not)', ['url'])
GAUGE_RT = Gauge('sample_external_url_response_ms', 'HTTP Response Time', ['url'])

# exit gracefully when ctrl+c is pressed
def shutdown(signal, frame):
    sys.exit(0)

# make the request and set the status_code and response time for prometheus
def response_guage(url):
    try:
        r = requests.get(url, timeout=2)
        if r.status_code == 200:
            GAUGE_UP.labels(url).set(1)
        else:
            GAUGE_UP.labels(url).set(0)
        GAUGE_RT.labels(url).set(r.elapsed.total_seconds()*1000)
        return r.status_code
    except:
        pass

if __name__ == '__main__':
    signal.signal(signal.SIGINT, shutdown)
    # Start up the server to expose the metrics.
    start_http_server(8000)
    # loop through the urls until exited
    while True:
        for url in urls:
            response_guage(url)
        time.sleep(5)