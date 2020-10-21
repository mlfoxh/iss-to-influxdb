FROM alpine:latest

COPY iss-to-influxdb.sh /root/iss-to-influxdb.sh

RUN apk update && apk add \
    bash \
    curl \
    jq

ENV INFLUXDB_ADDRESS=http://influxdb.domain.tld:8086
ENV INFLUXDB_DATABASE=database
ENV INFLUXDB_USER=user
ENV INFLUXDB_PASSWORD=password
ENV INTERVAL=15

ENTRYPOINT ["/bin/bash"]

CMD ["/root/iss-to-influxdb.sh"]
