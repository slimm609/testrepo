FROM python:3.7-alpine

WORKDIR /app
# copy requirements in first to take advantage of build caching
COPY requirements.txt /app
RUN apk add --no-cache curl && \
    pip3 install -r requirements.txt && \
    curl -sLo /bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 && \
    chmod +x /bin/dumb-init

COPY docker/start.sh /
COPY *.py /app/

# run dumb-init so that it takes over as pid 1 since python is not set up to handle pid 1 by default
ENTRYPOINT ["/bin/dumb-init", "--" ]
CMD ["/start.sh"]
