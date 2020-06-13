# Coding Challenge
The sample application should query 2 urls `"https://httpstat.us/200"` and `"https://httpstat.us/503"` and make the response time and status code available to Prometheus

## Run

### Local
To build the application locally
```bash
virtualenv -p python3 venv
source venv/bin/activate
pip3 install -r app/requirements.txt
python3 app/main.py
```
### Docker
To build and run with docker or docker-compose, use any of the choices below
```bash
docker build -t briandavis/pyapp:latest app/
docker run -it briandavis/pyapp:latest
```
```bash
docker-compose up
```
```bash
docker-compose run -p8000:8000 pyapp
```

### Kubernetes
To deploy to a kubernetes cluster using skaffold
```bash
cd app/
skaffold run
```

The deploy using kustomize and kubectl.
```bash
cd app/k8s
kustomize build . | kubectl apply -f -
```

### Kubernetes kind demo
To setup a local kind cluster and deploy the application.
```bash
./demo.sh up
```
It will take about 2-3 minutes to be fully up and running. 

![Demo](/images/term.svg)

Grafana can be reached at http://grafana.localtest.me with a demo login of `admin`/`admin`

Prometheus can be reached at http://prometheus.localtest.me

the App metrics can be reached at http://app.localtest.me/metrics/

when complete run `./demo.sh down` to stop the cluster.

## Tests
To run tests locally, if the venv was already set up from above.
```bash
pytest app/tests.py
```

To run tests in docker
```bash
docker run briandavis/pyapp app/tests.py
```
To run tests in docker-compose
```bash
docker-compose run unittests
```

## Metrics
Below is a snippet of the custom metrics exposed by the app

```
# HELP sample_external_url_up HTTP up or down (200 or not)
# TYPE sample_external_url_up gauge
sample_external_url_up{url="https://httpstat.us/200"} 1.0
sample_external_url_up{url="https://httpstat.us/503"} 0.0
# HELP sample_external_url_response_ms HTTP Response Time
# TYPE sample_external_url_response_ms gauge
sample_external_url_response_ms{url="https://httpstat.us/200"} 463.589
sample_external_url_response_ms{url="https://httpstat.us/503"} 508.015
```

## Screenshots

![Grafana](/images/grafana.png)

![prom-up](/images/prometheus_up.png)

![prom-response](/images/prometheus_response.png)
